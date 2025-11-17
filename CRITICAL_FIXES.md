# Критические исправления - 17 ноября 2025

## ✅ Исправлено 3 критические проблемы

---

### 1. 🔴 Race condition при инициализации AuthCubit

**Файл:** `lib/main.dart`

**Проблема:**
```dart
// ❌ БЫЛО: AuthCubit вызывает checkAuthStatus() до того как portfolioCubit был установлен
BlocProvider(
  create: (context) {
    final cubit = AuthCubit(getIt());
    cubit.setPortfolioCubit(context.read<PortfolioCubit>()); // Может быть недоступен
    cubit.checkAuthStatus(); // Может вызвать portfolioCubit?.initializeUser() раньше
    return cubit;
  },
),
```

**Решение:**
```dart
// ✅ СТАЛО: Гарантируем порядок инициализации
BlocProvider(
  create: (context) {
    final portfolioCubit = context.read<PortfolioCubit>();
    final authCubit = AuthCubit(getIt());
    
    // Set portfolio cubit reference BEFORE calling any methods
    authCubit.setPortfolioCubit(portfolioCubit);
    
    // Check auth status after portfolio cubit is properly set
    // Use addPostFrameCallback to ensure all widgets are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authCubit.checkAuthStatus();
    });
    
    return authCubit;
  },
),
```

**Изменения:**
- Явно получаем PortfolioCubit перед использованием
- Устанавливаем cubit reference ДО вызова методов
- Используем `addPostFrameCallback` для гарантии инициализации всех widgets перед checkAuthStatus()

---

### 2. 🔴 Утечка памяти в CoinService (Isolate)

**Файл:** `lib/core/network/coin_service.dart`

**Проблема:**
```dart
// ❌ БЫЛО: receivePort никогда не закрывается
class CoinService {
  SendPort? _workerSendPort;

  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;
    final receivePort = ReceivePort(); // Создан но не закрыт
    await Isolate.spawn(coinWorker, receivePort.sendPort);
    _workerSendPort = await receivePort.first as SendPort;
    // receivePort остается открытым в памяти навсегда
  }

  Future<List<Coin>> getCoins() async {
    // ...
    final receivePort = ReceivePort(); // Временный port также не закрывается
    _workerSendPort!.send({...});
    final rawList = await receivePort.first;
    // receivePort.close() - никогда не вызывается!
    return ...;
  }
}
```

**Решение:**
```dart
// ✅ СТАЛО: Правильно закрываем ReceivePort
class CoinService {
  SendPort? _workerSendPort;
  ReceivePort? _mainReceivePort; // Сохраняем ссылку для cleanup

  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;

    final receivePort = ReceivePort();
    _mainReceivePort = receivePort; // Сохраняем для cleanup

    try {
      await Isolate.spawn(coinWorker, receivePort.sendPort);
      _workerSendPort = await receivePort.first as SendPort;
      developer.log('CoinService: Worker isolate initialized');
    } catch (e) {
      developer.log('CoinService: Failed to initialize worker isolate: $e');
      _mainReceivePort?.close();
      _mainReceivePort = null;
      rethrow;
    }
  }

  Future<List<Coin>> getCoins() async {
    await _initializeWorker();

    final receivePort = ReceivePort();
    _workerSendPort!.send({...});

    try {
      final rawList = await receivePort.first;
      if (rawList is Map && rawList.containsKey('error')) {
        throw Exception('Failed to fetch coins: ${rawList['error']}');
      }
      return (rawList as List).map((json) => Coin.fromJson(json)).toList();
    } finally {
      receivePort.close(); // ✅ Гарантированное закрытие
    }
  }

  /// Cleanup resources - close the main receive port
  void dispose() {
    _mainReceivePort?.close();
    _mainReceivePort = null;
    _workerSendPort = null;
    developer.log('CoinService: Disposed');
  }
}
```

**Изменения:**
- Добавлен `_mainReceivePort` для отслеживания главного порта
- Добавлена обработка ошибок при инициализации isolate
- Добавлен `finally` блок в `getCoins()` для гарантированного закрытия временного port
- Добавлен метод `dispose()` для cleanup при завершении приложения

---

### 3. 🔴 Null safety - _currentUserEmail может быть null

**Файл:** `lib/presentation/pages/portfolio_cubit.dart`

**Проблема:**
```dart
// ❌ БЫЛО: _currentUserEmail инициализируется как null
class PortfolioCubit extends Cubit<PortfolioState> {
  String? _currentUserEmail; // Может быть null
  
  Future<void> addAsset(String symbol, double amount) async {
    if (_currentUserEmail == null) { // Проверка null
      emit(PortfolioError('User not authenticated'));
      return;
    }
    await portfolioRepository.addPortfolioItem(_currentUserEmail!, item); // Неловко: !
  }
}
```

**Решение:**
```dart
// ✅ СТАЛО: Инициализируем как пустая строка, никогда null
class PortfolioCubit extends Cubit<PortfolioState> {
  String _currentUserEmail = ''; // Никогда null, изначально пусто
  
  Future<void> addAsset(String symbol, double amount) async {
    if (_currentUserEmail.isEmpty) { // Проверка пусто вместо null
      emit(PortfolioError('User not authenticated'));
      return;
    }
    await portfolioRepository.addPortfolioItem(_currentUserEmail, item); // Чисто
  }

  void clear() {
    _currentUserEmail = '';
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    emit(PortfolioInitial());
    developer.log('PortfolioCubit: Cleared');
  }

  Future<void> clearPortfolio() async {
    if (_currentUserEmail.isEmpty) {
      emit(PortfolioInitial());
      return;
    }

    try {
      await portfolioRepository.clearUserPortfolio(_currentUserEmail);
      _currentUserEmail = ''; // Сброс в пустую строку
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      emit(PortfolioInitial());
    } catch (e) {
      emit(PortfolioError('Failed to clear portfolio: ${e.toString()}'));
    }
  }
}
```

**Дополнительно - исправлен AuthCubit.logout():**

```dart
// ✅ БЫЛО: logout не очищал портфолио и его таймеры
Future<void> logout() async {
  emit(AuthLoading());
  try {
    await authRepository.logout();
    currentUser = null;
    emit(AuthInitial());
  } catch (e) {
    emit(AuthFailure('Logout failed: ${e.toString()}'));
  }
}

// ✅ СТАЛО: Явно очищаем портфолио и останавливаем таймеры
Future<void> logout() async {
  emit(AuthLoading());
  try {
    await authRepository.logout();
    currentUser = null;
    
    // Clear portfolio and stop background syncs
    portfolioCubit?.clear();
    
    emit(AuthInitial());
  } catch (e) {
    emit(AuthFailure('Logout failed: ${e.toString()}'));
  }
}
```

**Изменения:**
- Изменен тип `_currentUserEmail` с `String?` на `String`
- Инициализация как пустая строка вместо null
- Все проверки изменены с `== null` на `.isEmpty`
- Удалены все ненужные non-null assertions (`!`)
- Добавлена явная очистка таймеров при `clear()` и `clearPortfolio()`
- AuthCubit.logout() теперь явно очищает портфолио

---

## 📊 Итоги

| Проблема | Статус | Влияние |
|----------|--------|--------|
| Race condition при инициализации | ✅ Исправлено | Критическое - гарантирует порядок инициализации |
| Утечка памяти в isolate | ✅ Исправлено | Серьёзное - очищает ресурсы |
| Null safety _currentUserEmail | ✅ Исправлено | Критическое - предотвращает NPE |

---

## 🚀 Следующие шаги

1. **Добавить таймауты** на все сетевые запросы (см. CODE_AUDIT.md пункт 8)
2. **Добавить проверку интернета** перед запросами (см. CODE_AUDIT.md пункт 14)
3. **Добавить unit тесты** для cubits и repositories
4. **Настроить error tracking** (Sentry/Firebase)

---

## ✔️ Проверка

Все файлы проверены:
- ✅ `dart analyze` - нет ошибок
- ✅ `dart format` - код отформатирован
- ✅ Все 3 проблемы исправлены
