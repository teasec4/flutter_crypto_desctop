# Quick Reference - Быстрый поиск

## 🎯 Нужно найти файл?

### Аутентификация (Login, Register, Logout)
```
lib/presentation/pages/login_page.dart          ← UI для логина
lib/presentation/pages/register_page.dart       ← UI для регистрации
lib/presentation/pages/auth_cubit.dart          ← Логика (login, logout, checkAuth)
lib/presentation/pages/auth_state.dart          ← Состояния
lib/data/datasource/auth_remote_datasource.dart ← Supabase API
```

### Монеты (Список, Детали)
```
lib/presentation/pages/content_view.dart         ← Список монет
lib/presentation/pages/coin_cubit.dart           ← Загрузка монет
lib/presentation/coin/coin_tile.dart             ← Карточка монеты
lib/presentation/pages/coin_detail_page.dart     ← Детали монеты
lib/data/datasource/coin_remote_datasource.dart  ← CoinGecko API
lib/domain/models/coin.dart                      ← Модель монеты
```

### Портфель
```
lib/presentation/pages/portfolio_page.dart       ← Экран портфеля
lib/presentation/pages/portfolio_cubit.dart      ← Логика (add, remove, load)
lib/presentation/pages/portfolio_state.dart      ← Состояния
lib/data/datasource/portfolio_remote_datasource.dart ← Supabase API
lib/domain/models/portfolio_item.dart            ← Модель портфеля
```

### Настройки
```
lib/presentation/pages/settings_view.dart        ← Экран настроек
lib/core/theme/theme_cubit.dart                  ← Переключение темы
```

### Темы и Оформление
```
lib/core/theme/app_theme.dart                    ← Светлая + Темная тема
lib/core/constants/app_constants.dart            ← Константы (breakpoints, routes)
```

### DI и Инициализация
```
lib/di/service_locator.dart                      ← Регистрация сервисов
lib/main.dart                                    ← Точка входа, BlocProviders
```

### Навигация
```
lib/router/app_router.dart                       ← Все routes приложения
```

---

## 🔧 Я хочу изменить...

### Внешний вид списка монет
→ `lib/presentation/pages/content_view.dart` или `lib/presentation/coin/coin_tile.dart`

### Как загружаются монеты
→ `lib/presentation/pages/coin_cubit.dart` (метод `loadCoins()`)

### API для получения монет
→ `lib/data/datasource/coin_remote_datasource_impl.dart`

### Экран портфеля
→ `lib/presentation/pages/portfolio_page.dart`

### Добавление/удаление ассетов
→ `lib/presentation/pages/portfolio_cubit.dart` (методы `addAsset`, `removeAsset`)

### Сохранение портфеля на сервер
→ `lib/data/datasource/portfolio_remote_datasource_impl.dart`

### Цвета в приложении
→ `lib/core/theme/app_theme.dart` (светлая: lightTheme(), темная: darkTheme())

### Как переключается тема
→ `lib/presentation/pages/settings_view.dart` + `lib/core/theme/theme_cubit.dart`

### Маршруты (Routes) приложения
→ `lib/router/app_router.dart`

### Размеры экрана (Responsive)
→ `lib/core/constants/app_constants.dart` (breakpoints)

---

## 📊 Поток данных по фичерам

### 📱 Загрузка списка монет

```
content_view.dart
  ↓ (нажимаем экран)
coin_cubit.dart loadCoins()
  ↓
coin_repository_impl.dart getCoins()
  ↓
coin_remote_datasource_impl.dart getCoins()
  ↓
CoinGecko API
  ↓ (список JSON)
coin_remote_datasource_impl.dart (парсим)
  ↓
coin_local_datasource_impl.dart (кешируем в Isar)
  ↓
coin_cubit.dart emit(CoinLoaded(coins))
  ↓
content_view.dart (показываем ListView)
```

### 🔐 Вход в приложение

```
login_page.dart (ввели email/password)
  ↓ (нажали "Login")
auth_cubit.dart login()
  ↓
auth_repository_impl.dart login()
  ↓
auth_remote_datasource_impl.dart login()
  ↓
Supabase.auth.signInWithPassword()
  ↓ (получили User)
user_local_datasource_impl.dart saveUser() (Isar)
  ↓
auth_cubit.dart emit(AuthSuccess())
  ↓
router.dart go('/')
```

### 💼 Добавление монеты в портфель

```
coin_tile.dart (нажали + button)
  ↓
_AddToPortfolioSheet (модальное окно)
  ↓ (ввели количество, нажали Add)
portfolio_cubit.dart addAsset()
  ↓
portfolio_repository_impl.dart addPortfolioItem()
  ↓
portfolio_remote_datasource_impl.dart addPortfolioItem()
  ↓
Supabase.from('portfolios').insert()
  ↓ (успешно)
portfolio_cubit.dart loadPortfolio() (перезагружаем)
  ↓
portfolio_page.dart (обновляется список)
```

### 🌓 Переключение темы

```
settings_view.dart (нажали Switch)
  ↓
theme_cubit.dart setDarkMode()
  ↓
emit(ThemeDark() или ThemeLight())
  ↓
main.dart BlocBuilder<ThemeCubit> (слушает изменения)
  ↓
MaterialApp(theme: ..., darkTheme: ...)
  ↓
Все цвета обновляются автоматически
```

---

## 🆘 Ошибки и решения

### "The method 'xyz' isn't defined"
→ Проверь что класс зарегистрирован в `service_locator.dart`

### "State is null" 
→ Проверь что Cubit emit'ит состояние перед использованием

### "Build called during build"
→ Не вызывай context.read() при построении widget'а, используй initState()

### Цвета не меняются при смене темы
→ Используй `Theme.of(context)` вместо hardcoded `Colors.white`

### Данные не сохраняются
→ Проверь что repository правильно обращается к datasource

### API не отвечает
→ Проверь интернет, Supabase keys в main.dart, URL в datasource

---

## 📝 Структура нового Cubit'а

```dart
import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/my_model.dart';
import 'package:crypto_desctop/domain/repository/my_repo.dart';

part 'my_state.dart';

class MyCubit extends Cubit<MyState> {
  final MyRepository myRepository;
  
  MyCubit(this.myRepository) : super(MyInitial());
  
  Future<void> loadData() async {
    emit(MyLoading());
    try {
      final data = await myRepository.getData();
      emit(MyLoaded(data));
    } catch (e) {
      emit(MyError(e.toString()));
    }
  }
}
```

```dart
// my_state.dart
part of 'my_cubit.dart';

sealed class MyState {}

final class MyInitial extends MyState {}
final class MyLoading extends MyState {}
final class MyLoaded extends MyState {
  final List<MyModel> data;
  MyLoaded(this.data);
}
final class MyError extends MyState {
  final String message;
  MyError(this.message);
}
```

---

## 🎨 Адаптивный цвет (Light/Dark)

```dart
// Плохо - не адаптируется
Color color = Colors.white;  // ❌

// Хорошо - адаптируется
Color color = Theme.of(context).colorScheme.surface;  // ✅

// Для вторичного текста
Color _getSecondaryTextColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
}
```

---

## 🔑 Главные концепции

| Концепция | Назначение | Файлы |
|-----------|-----------|-------|
| **Cubit** | Управление состоянием | `*_cubit.dart` |
| **State** | Разные состояния UI | `*_state.dart` |
| **Repository** | Интерфейс данных | `domain/repository/` |
| **DataSource** | Источник данных (API/БД) | `data/datasource/` |
| **Model** | Структура данных | `models/` |
| **GetIt** | Dependency Injection | `service_locator.dart` |
| **BLoC Pattern** | State Management | Весь проект |
| **Clean Arch** | Разделение слоев | Папки lib/ |

---

## 🚀 Самые важные файлы (запомни путь!)

```
lib/presentation/pages/auth_cubit.dart          ← Логика входа/выхода
lib/presentation/pages/portfolio_cubit.dart     ← Логика портфеля
lib/presentation/pages/coin_cubit.dart          ← Загрузка монет
lib/core/theme/app_theme.dart                   ← Темы (цвета, шрифты)
lib/main.dart                                   ← Инициализация
lib/di/service_locator.dart                     ← Регистрация сервисов
```

Эти 6 файлов - основа всего приложения!
