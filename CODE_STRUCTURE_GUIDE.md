# Полный гайд по структуре проекта

## 📂 Структура папок

```
lib/
├── core/                    # Ядро приложения (темы, константы)
│   ├── constants/          # Магические числа
│   │   └── app_constants.dart
│   └── theme/              # Оформление
│       ├── app_theme.dart  # Светлая + темная тема
│       └── theme_cubit.dart # Переключение тем
│
├── data/                   # Получение данных (API, БД)
│   ├── datasource/         # Откуда берем данные
│   │   ├── *_remote_datasource.dart  (API)
│   │   └── *_local_datasource.dart   (БД Isar)
│   ├── models/             # Модели для сериализации
│   │   └── isar_*.dart
│   └── repository/         # Логика получения данных
│       └── *_repository_impl.dart
│
├── domain/                 # Бизнес-логика
│   ├── models/             # Модели для бизнеса (User, Coin, Portfolio)
│   └── repository/         # Интерфейсы репозиториев (абстракция)
│       └── *_repo.dart (interface)
│
├── presentation/           # UI (что видит юзер)
│   ├── pages/              # Целые экраны
│   │   ├── *_page.dart     # Виджет-контейнер
│   │   ├── *_cubit.dart    # Состояние логики
│   │   └── *_state.dart    # Определение состояний
│   ├── coin/               # Компоненты для монет
│   │   └── coin_tile.dart  # Карточка монеты
│   └── router/             # Навигация между экранами
│
├── di/                     # Dependency Injection (GetIt)
│   └── service_locator.dart # Регистрация всех сервисов
│
└── main.dart               # Точка входа
```

---

## 🔄 Поток данных (Data Flow)

### ✨ Общий принцип: Clean Architecture

```
UI (Widget) 
  ↓
Cubit (Управление состоянием)
  ↓
Repository (Интерфейс бизнес-логики)
  ↓
DataSource (API / БД)
  ↓
Сервер / Локальная БД
```

### 📝 Пример 1: Загрузка списка монет

**Файл:** `lib/presentation/pages/content_view.dart`
```dart
BlocBuilder<CoinCubit, CoinState>(
  builder: (context, state) {
    if (state is CoinLoaded) {
      // Показываем монеты
      return ListView(
        children: state.coins.map((coin) => CoinTile(coin: coin))
      );
    }
  }
)
```

**Что происходит:**
1. UI вызывает `CoinCubit().loadCoins()`
2. Cubit обращается к `CoinRepository.getCoins()`
3. Repository идет в `CoinRemoteDataSource.getCoins()` (API)
4. API возвращает JSON
5. DataSource преобразует в `List<Coin>`
6. Repository возвращает монеты Cubit
7. Cubit emit'ит `CoinLoaded(coins)`
8. UI обновляется

**Файлы:**
- `lib/presentation/pages/coin_cubit.dart` ← куда добавлять логику
- `lib/domain/repository/coin_repo.dart` ← интерфейс
- `lib/data/repository/coin_repository_impl.dart` ← реализация
- `lib/data/datasource/coin_remote_datasource_impl.dart` ← API

---

### 👤 Пример 2: Аутентификация (Login)

**Файл:** `lib/presentation/pages/login_page.dart`
```dart
ElevatedButton(
  onPressed: () => context.read<AuthCubit>().login(email, password),
  child: Text('Login'),
)
```

**Поток:**
```
login_page.dart (нажать кнопку)
  ↓
AuthCubit.login(email, password)
  ↓
AuthRepository.login()
  ↓
AuthRemoteDataSource.login() (Supabase API)
  ↓
Получаем User
  ↓
Сохраняем в Isar (локально)
  ↓
emit(AuthSuccess())
  ↓
UI редиректит на '/'
```

**Файлы:**
- `lib/presentation/pages/auth_cubit.dart` ← логика
- `lib/data/datasource/auth_remote_datasource_impl.dart` ← Supabase
- `lib/data/datasource/user_local_datasource_impl.dart` ← Isar БД

---

### 💼 Пример 3: Портфель (Portfolio)

**Загрузка портфеля:**
```dart
context.read<PortfolioCubit>().loadPortfolio(userEmail)
```

**Поток:**
```
Portfolio нужны данные для юзера
  ↓
PortfolioCubit.loadPortfolio(email)
  ↓
PortfolioRepository.getPortfolioItems(email)
  ↓
PortfolioRemoteDataSource (Supabase)
  ↓
Получаем список ассетов [BTC, ETH, ...]
  ↓
Обогащаем ценами через CoinRepo
  ↓
emit(PortfolioLoaded(items))
```

**Файлы:**
- `lib/presentation/pages/portfolio_cubit.dart` ← главная логика
- `lib/data/datasource/portfolio_remote_datasource_impl.dart` ← Supabase
- Использует `CoinRepo` для текущих цен

---

## 🎮 Cubits (Управление состоянием)

Cubit = класс который:
1. Хранит состояние
2. Имеет методы для изменения состояния
3. Emit'ит новые состояния

### AuthCubit - Аутентификация

**Файл:** `lib/presentation/pages/auth_cubit.dart`

```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  User? currentUser;  // Текущий юзер

  AuthCubit(this.authRepository) : super(AuthInitial());

  // Методы для действий
  Future<void> login(String email, String password) async {
    emit(AuthLoading());  // Показываем загрузку
    try {
      currentUser = await authRepository.login(email, password);
      emit(AuthSuccess());  // Успех
    } catch (e) {
      emit(AuthFailure(e.toString()));  // Ошибка
    }
  }

  Future<void> logout() async {
    currentUser = null;
    emit(AuthInitial());
  }

  String? getCurrentUserEmail() => currentUser?.email;
}
```

**Состояния:** `lib/presentation/pages/auth_state.dart`
```dart
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState { final String message; }
```

### PortfolioCubit - Портфель

**Файл:** `lib/presentation/pages/portfolio_cubit.dart`

```dart
class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final CoinRepo coinRepo;  // Для получения цен
  String? _currentUserEmail;

  PortfolioCubit({required this.portfolioRepository, required this.coinRepo})
      : super(PortfolioInitial());

  // Загрузить портфель юзера
  Future<void> loadPortfolio(String userEmail) async {
    _currentUserEmail = userEmail;
    emit(PortfolioLoading());
    try {
      final items = await portfolioRepository.getPortfolioItems(userEmail);
      final enriched = await _enrichItemsWithPrices(items);
      emit(PortfolioLoaded(enriched));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  // Добавить монету в портфель
  Future<void> addAsset(String symbol, double amount) async {
    if (_currentUserEmail == null) return;
    try {
      final item = PortfolioItem(...);
      await portfolioRepository.addPortfolioItem(_currentUserEmail!, item);
      await loadPortfolio(_currentUserEmail!);  // Перезагружаем
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  // Очистить при logout
  void clear() {
    _currentUserEmail = null;
    emit(PortfolioInitial());
  }
}
```

### ThemeCubit - Темы

**Файл:** `lib/core/theme/theme_cubit.dart`

```dart
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeLight());

  bool get isDark => state is ThemeDark;

  void toggleTheme() {
    emit(state is ThemeLight ? ThemeDark() : ThemeLight());
  }

  void setDarkMode(bool isDark) {
    emit(isDark ? ThemeDark() : ThemeLight());
  }
}
```

---

## 📦 Repositories (Интерфейсы)

### Интерфейс: `lib/domain/repository/`

```dart
// coin_repo.dart (интерфейс)
abstract class CoinRepo {
  Future<List<Coin>> getCoins();
  Future<Coin> getCoin(String id);
}

// coin_repository_impl.dart (реализация)
class CoinRepositoryImpl implements CoinRepo {
  final CoinLocalDatasource localDatasource;
  final CoinRemoteDatasource remoteDatasource;

  @override
  Future<List<Coin>> getCoins() async {
    try {
      // Сначала пробуем сеть
      final coins = await remoteDatasource.getCoins();
      // Кешируем локально
      await localDatasource.saveCoinsList(coins);
      return coins;
    } catch (e) {
      // Если нет сети, берем из кеша
      return localDatasource.getCoinsList();
    }
  }
}
```

---

## 🔌 Dependency Injection (GetIt)

**Файл:** `lib/di/service_locator.dart`

```dart
final getIt = GetIt.instance;

void setupServiceLocator(Isar isar) {
  // Регистрируем все сервисы
  
  // 1. Isar БД
  getIt.registerSingleton<Isar>(isar);
  
  // 2. Coin сервисы
  getIt.registerSingleton<CoinLocalDatasource>(
    CoinLocalDatasourceImpl(getIt<Isar>()),
  );
  getIt.registerSingleton<CoinRemoteDatasource>(
    CoinRemoteDatasourceImpl(),
  );
  getIt.registerSingleton<CoinRepo>(
    CoinRepositoryImpl(
      localDatasource: getIt<CoinLocalDatasource>(),
      remoteDatasource: getIt<CoinRemoteDatasource>(),
    ),
  );
  
  // 3. Auth сервисы
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(Supabase.instance.client),
  );
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<UserLocalDataSource>(),
    ),
  );
}
```

**Использование:**
```dart
// Вместо new CoinRepository() - берем из GetIt
final coinRepo = getIt<CoinRepo>();
context.read<CoinCubit>().loadCoins();
```

---

## 🎨 UI слой

### Экран (Page)

```dart
// portfolio_page.dart
class PortfolioPage extends StatefulWidget {
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  @override
  void initState() {
    super.initState();
    _loadPortfolioData();  // Загружаем при открытии
  }

  void _loadPortfolioData() {
    final authCubit = context.read<AuthCubit>();
    final userEmail = authCubit.getCurrentUserEmail();
    if (userEmail != null) {
      context.read<PortfolioCubit>().loadPortfolio(userEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return CircularProgressIndicator();
        } else if (state is PortfolioLoaded) {
          return ListView(
            children: state.items.map((item) => _buildTile(item))
          );
        }
      }
    );
  }
}
```

---

## 🔍 Как найти то, что тебе нужно

### Нужно добавить новую функцию загрузки?
1. Проверь `domain/repository/` - есть ли интерфейс?
2. Если нет - создай интерфейс
3. Реализуй в `data/repository/`
4. Добавь datasource в `data/datasource/`
5. Зарегистрируй в `di/service_locator.dart`
6. Используй в Cubit

### Нужно изменить внешний вид?
1. Файлы UI: `presentation/pages/` и `presentation/coin/`
2. Темы: `core/theme/app_theme.dart`
3. Константы: `core/constants/app_constants.dart`

### Нужно добавить новое состояние?
1. Создай в `*_state.dart` файле
2. Обработай в Cubit'е emit'ом
3. Обработай в UI с `BlocBuilder`

### Нужно загрузить данные из API?
1. Создай datasource в `data/datasource/`
2. Используй в Repository
3. Repository используй в Cubit
4. Cubit используй в UI

---

## 📱 Точка входа

**Файл:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Инициализация Supabase
  await Supabase.initialize(...);
  
  // 2. Инициализация локальной БД (Isar)
  final isar = await Isar.open([...]);
  
  // 3. Регистрируем все сервисы
  setupServiceLocator(isar);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => PortfolioCubit(...)),
        BlocProvider(
          create: (context) {
            final cubit = AuthCubit(getIt());
            cubit.checkAuthStatus();  // Проверяем залогинен ли
            return cubit;
          },
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
      ),
    );
  }
}
```

---

## ✅ Чек-лист для частых задач

### Добавить новое поле в User
- [ ] Добавить в `domain/models/user_model.dart`
- [ ] Обновить Supabase schema
- [ ] Обновить Isar модель в `data/models/isar_user_model.dart`
- [ ] Обновить datasource

### Добавить новую страницу
- [ ] Создать `presentation/pages/new_page.dart`
- [ ] Создать Cubit если нужна логика
- [ ] Добавить в router `lib/router/app_router.dart`
- [ ] Добавить в навигацию

### Изменить тему
- [ ] Отредактировать `core/theme/app_theme.dart`
- [ ] Light theme и Dark theme отдельно
- [ ] Перезагрузить приложение (Hot Reload может не подхватить)

### Добавить новый API запрос
- [ ] Создать метод в `data/datasource/*_remote_datasource.dart`
- [ ] Добавить в Repository интерфейс
- [ ] Реализовать в Repository impl
- [ ] Использовать в Cubit методе

---

## 🚀 Быстрый старт при изменениях

1. **Юзер видит что-то не так на экране?**
   → Ищи файл в `presentation/pages/` или `presentation/coin/`

2. **Данные не загружаются?**
   → Проверь Cubit → Repository → DataSource

3. **API не работает?**
   → Проверь DataSource и Supabase configuration

4. **Состояние не обновляется?**
   → Проверь что Cubit emit'ит правильное состояние

5. **Цвета не меняются при смене темы?**
   → Используй `Theme.of(context)` вместо hardcoded Colors

---

## 📚 Дополнительно

- **BLoC Pattern:** State management через Cubit
- **Clean Architecture:** Разделение на слои (UI, Domain, Data)
- **Repository Pattern:** Абстракция источников данных
- **Dependency Injection:** GetIt для управления зависимостями
- **Isar:** Локальная БД для кеширования
- **Supabase:** Backend для аутентификации и данных

Все эти паттерны позволяют писать код, который легко тестировать и менять.
