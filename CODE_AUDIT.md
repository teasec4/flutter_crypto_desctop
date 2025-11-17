# Аудит кода - Потенциальные проблемы и улучшения

## 🔴 КРИТИЧЕСКИЕ ПРОБЛЕМЫ

### 1. **Раскрытие конфиденциальной информации в main.dart (SECURITY)**
**Файл:** `lib/main.dart:29-31`

```dart
await Supabase.initialize(
  url: 'https://bucuwdkctsufqxgspoqw.supabase.co',
  anonKey: '[REDACTED:jwt-token]', // ❌ API ключи в коде
);
```

**Проблема:** Supabase URL и Anonymous ключ захардкодены в приложении. Это приемлемо для `anonKey` (он предназначен для публичного использования), но URL и ключ должны быть в конфиге.

**Рекомендация:**
- Переместить в `pubspec.yaml` или конфиг файл
- Использовать `--dart-define` для разных сред (dev, prod)
- Или загружать из secure storage при инициализации

---

### 2. **Race condition при инициализации Cubits (CONCURRENCY)**
**Файл:** `lib/main.dart:69-87`

```dart
BlocProvider(
  create: (context) {
    final coinCubit = CoinCubit(getIt<CoinRepo>());
    coinCubit.loadCoins(); // Загрузка начинается до полной инициализации
    return coinCubit;
  },
),
BlocProvider(
  create: (context) {
    final cubit = AuthCubit(getIt());
    cubit.setPortfolioCubit(context.read<PortfolioCubit>()); // ❌ Race condition
    cubit.checkAuthStatus();
    return cubit;
  },
),
```

**Проблема:** 
- `setPortfolioCubit()` вызывается через `context.read()`, но PortfolioCubit может еще инициализироваться
- `checkAuthStatus()` может вызвать `portfolioCubit?.initializeUser()` до того как тот был установлен

**Рекомендация:**
- Использовать явный порядок инициализации через Future.delayed или StreamController
- Или добавить флаг инициализации в PortfolioCubit

---

### 3. **Null safety нарушение в portfolio операциях (LOGIC)**
**Файл:** `lib/presentation/pages/portfolio_cubit.dart:156-179`

```dart
Future<void> addAsset(String symbol, double amount) async {
  if (_currentUserEmail == null) {
    emit(PortfolioError('User not authenticated'));
    return;
  }
  // ...
}
```

**Проблема:** `_currentUserEmail` инициализируется как null, но методы addAsset/updateAsset/removeAsset полагаются на то, что он установлен. Если пользователь выполнит операцию до инициализации - ошибка.

**Рекомендация:**
- Инициализировать `_currentUserEmail` в конструкторе или через явное задание
- Или использовать `late` с проверкой перед использованием

---

## 🟠 СЕРЬЁЗНЫЕ ПРОБЛЕМЫ

### 4. **Утечка памяти в isolate (CoinService)**
**Файл:** `lib/core/network/coin_service.dart`

```dart
class CoinService {
  SendPort? _workerSendPort;

  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;
    final receivePort = ReceivePort();
    await Isolate.spawn(coinWorker, receivePort.sendPort);
    _workerSendPort = await receivePort.first as SendPort;
    // ❌ receivePort никогда не закрывается
  }
}
```

**Проблема:** 
- `receivePort` не закрывается после получения sendPort
- Isolate остается в памяти до завершения приложения

**Рекомендация:**
```dart
Future<void> _initializeWorker() async {
  if (_workerSendPort != null) return;
  final receivePort = ReceivePort();
  await Isolate.spawn(coinWorker, receivePort.sendPort);
  _workerSendPort = await receivePort.first as SendPort;
  receivePort.close(); // ✅ Закрыть порт
}
```

---

### 5. **Обработка ошибок при logout без очистки таймеров (LOGIC)**
**Файл:** `lib/presentation/pages/auth_cubit.dart:62-72`

```dart
Future<void> logout() async {
  emit(AuthLoading());
  try {
    await authRepository.logout();
    currentUser = null;
    emit(AuthInitial());
    // ❌ Не очищается portfolioCubit, не останавливаются таймеры
  } catch (e) {
    emit(AuthFailure('Logout failed: ${e.toString()}'));
  }
}
```

**Проблема:**
- При logout таймеры в PortfolioCubit и CoinCubit продолжают работать
- Портфолио остается в памяти

**Рекомендация:**
```dart
Future<void> logout() async {
  emit(AuthLoading());
  try {
    await authRepository.logout();
    currentUser = null;
    // Очистить портфолио и его таймеры
    portfolioCubit?.clear();
    emit(AuthInitial());
  } catch (e) {
    emit(AuthFailure('Logout failed: ${e.toString()}'));
  }
}
```

---

### 6. **Неправильное использование async в _fetchAndCachePortfolioItems (LOGIC)**
**Файл:** `lib/data/repository/portfolio_repository_impl.dart:52-60`

```dart
Future<void> _fetchAndCachePortfolioItems(String userEmail) async {
  try {
    final remoteItems = await remoteDataSource.getPortfolioItems(userEmail);
    await localDataSource.cachePortfolioItems(userEmail, remoteItems);
    developer.log('PortfolioRepository: Background sync completed');
  } catch (e) {
    developer.log('PortfolioRepository: Background sync failed - $e');
  }
}
```

**Проблема:** Вызывается БЕЗ `await` в `getPortfolioItems()`, поэтому Future может быть потеряна если приложение закроется. Нет обработки таймаутов.

**Рекомендация:**
```dart
void _fetchAndCachePortfolioItemsInBackground(String userEmail) {
  Future.delayed(const Duration(milliseconds: 100), () async {
    try {
      final remoteItems = await remoteDataSource
          .getPortfolioItems(userEmail)
          .timeout(const Duration(seconds: 10));
      await localDataSource.cachePortfolioItems(userEmail, remoteItems);
    } catch (e) {
      developer.log('Background sync failed: $e');
    }
  });
}
```

---

### 7. **Параметр userEmail игнорируется в Portfolio операциях (LOGIC)**
**Файл:** `lib/data/datasource/portfolio_remote_datasource_impl.dart`

```dart
Future<void> addPortfolioItem(String userEmail, PortfolioItem item) async {
  try {
    final userId = _supabase.auth.currentUser?.id; // ❌ userEmail не используется
    // ...
  }
}
```

**Проблема:** 
- Параметр `userEmail` передается но игнорируется
- Всегда использует `currentUser` из auth
- Потенциально опасно если у пользователя будет несколько сессий

**Рекомендация:**
- Удалить параметр `userEmail` из сигнатур методов или использовать его для валидации
- Или использовать для мультиаккаунта поддержки

---

## 🟡 СРЕДНЕСИЛЬНЫЕ ПРОБЛЕМЫ

### 8. **Отсутствие таймаутов на сетевых запросах**
**Файлы:** Все datasources с network запросами

```dart
final response = await _supabase.from(_table).select().eq('user_id', userId);
// ❌ Нет таймаута, может зависнуть навсегда
```

**Рекомендация:**
```dart
final response = await _supabase
    .from(_table)
    .select()
    .eq('user_id', userId)
    .timeout(const Duration(seconds: 15));
```

---

### 9. **CoinCubit загружается сразу при старте (PERFORMANCE)**
**Файл:** `lib/main.dart:70-72`

```dart
BlocProvider(
  create: (context) {
    final coinCubit = CoinCubit(getIt<CoinRepo>());
    coinCubit.loadCoins(); // ❌ Загружается даже если пользователь не авторизован
    return coinCubit;
  },
),
```

**Проблема:** 
- CoinCubit начинает загружаться до проверки auth статуса
- Может быть ненужная загрузка, если пользователь откроет только портфолио

**Рекомендация:**
- Загружать CoinCubit только при первом открытии ContentPage
- Или отложить инициализацию до AuthAuthenticated статуса

---

### 10. **Отсутствие обработки пустых данных в PortfolioPage (UX)**
**Файл:** `lib/presentation/pages/portfolio_page.dart:24-37`

```dart
if (state.items.isEmpty) {
  return RefreshIndicator(
    onRefresh: () => context.read<PortfolioCubit>().refreshPortfolio(),
    child: Center(
      child: Text('No assets in portfolio...'),
    ),
  );
}
```

**Проблема:** 
- RefreshIndicator с пустым списком - пользователь не может понять как обновить
- Нет различия между "первой загрузкой" и "действительно пусто"

**Рекомендация:**
- Добавить загрузку и ошибку состояния в пустой экран
- Или кнопку "Add first asset"

---

### 11. **Email валидация в login_page.dart слишком простая (VALIDATION)**
**Файл:** `lib/presentation/pages/login_page.dart:67`

```dart
if (!text.contains("@")) {
  return 'Please enter valid email';
}
```

**Проблема:** Не валидирует доменную часть, несколько @, и т.д.

**Рекомендация:**
```dart
final emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);
if (!emailRegex.hasMatch(text)) {
  return 'Please enter valid email';
}
```

---

### 12. **Отсутствие обработки ошибок network в _enrichItemsWithPrices (ERROR HANDLING)**
**Файл:** `lib/presentation/pages/portfolio_cubit.dart:124-153`

```dart
Future<List<PortfolioItem>> _enrichItemsWithPrices(
  List<PortfolioItem> items,
) async {
  try {
    final allCoins = await coinRepo.getCoins();
    // ...
  } catch (e) {
    debugPrint('Error enriching portfolio items with prices: $e');
    return items; // ❌ Молча возвращает старые цены
  }
}
```

**Проблема:** Если getCoins() сломается, пользователь не узнает что цены устаревшие

**Рекомендация:**
- Добавить флаг в state что цены устаревшие
- Показать warning что данные могут быть неактуальными

---

### 13. **Отсутствие debounce при быстрых переключениях вкладок**
**Проблема:** Если быстро переключать вкладки, может быть множество одновременных запросов

**Рекомендация:** Добавить debounce или cancel предыдущих запросов:
```dart
Future<void> loadCoins() async {
  _loadCoinsTimer?.cancel();
  _loadCoinsTimer = Timer(Duration(milliseconds: 300), () {
    // Выполнить загрузку
  });
}
```

---

### 14. **Отсутствие проверки интернета (CONNECTIVITY)**
**Проблема:** Нет проверки наличия интернета перед запросами

**Рекомендация:**
- Добавить `connectivity_plus` пакет
- Показывать состояние "Offline" когда нет интернета
- Использовать только кэш при offline

---

### 15. **Image.network без errorBuilder для всех монет (UI)**
**Файлы:** `lib/presentation/coin/coin_tile.dart`, `lib/presentation/pages/portfolio_page.dart`

```dart
Image.network(
  coin.imageUrl,
  width: 40,
  height: 40,
  errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, size: 40),
)
```

**Рекомендация:** 
- Добавить `loadingBuilder` для показания скелета во время загрузки
- Кэшировать изображения через `cached_network_image` пакет

---

## 🟢 НЕЗНАЧИТЕЛЬНЫЕ/УЛУЧШЕНИЯ

### 16. **Магические строки вместо констант**
**Примеры:**
- `'portfolio'` в portfolio_remote_datasource_impl.dart
- `/` в router
- `100` (perPage) в coin_cubit.dart

**Рекомендация:** Вынести в `AppConstants`

---

### 17. **Отсутствие логирования успешных операций**
**Проблема:** Только логируются ошибки и некоторые действия

**Рекомендация:** Добавить логирование ключевых моментов для отладки

---

### 18. **PortfolioCubit создается но может не инициализироваться**
**Файл:** `lib/main.dart:75-78`

```dart
BlocProvider(
  create: (context) =>
      PortfolioCubit(portfolioRepository: getIt(), coinRepo: getIt()),
),
```

**Проблема:** PortfolioCubit создается но `loadPortfolioInitial()` не вызывается здесь, только в AuthCubit

**Рекомендация:** Либо вызвать здесь, либо добавить явный инициальный стейт

---

### 19. **Отсутствие тестов**
**Проблема:** Нет unit/widget тестов

**Рекомендация:** Добавить тесты для:
- Cubits (state transitions)
- Repositories (cache vs network logic)
- Datasources (API parsing)
- Widgets (UI interactions)

---

### 20. **Отсутствие Error Tracking (Sentry/Firebase)**
**Проблема:** Ошибки только логируются локально

**Рекомендация:** Добавить Sentry для отслеживания ошибок в production

---

## 📊 СВОДКА ПО ПРИОРИТЕТАМ

| Уровень | Количество | Примеры |
|---------|-----------|---------|
| 🔴 Критические | 3 | Security (API keys), Race conditions, Null safety |
| 🟠 Серьёзные | 4 | Memory leaks, Error handling, Logic bugs |
| 🟡 Среднесильные | 5 | Timeouts, Performance, Validation |
| 🟢 Улучшения | 8 | Code quality, Testing, Monitoring |

---

## 🚀 ПЛАН ДЕЙСТВИЙ

### Фаза 1 (Срочно - 1-2 дня)
1. Исправить race condition в initialization
2. Добавить таймауты на все сетевые запросы
3. Закрыть receivePort в CoinService

### Фаза 2 (Важно - 3-5 дней)
4. Исправить null safety проблемы
5. Добавить cleanup при logout
6. Добавить обработку offline состояния

### Фаза 3 (Нужно - 1-2 недели)
7. Добавить unit тесты
8. Добавить Sentry/error tracking
9. Оптимизировать загрузку при старте
10. Улучшить UX пустых состояний

### Фаза 4 (Желательно - постоянно)
11. Рефакторинг магических строк
12. Добавить проверку интернета
13. Улучшить image caching
14. Добавить более детальное логирование
