# 📋 Примеры кода для частых задач

## 1️⃣ Добавить новое поле в Coin

### Шаг 1: Модель в domain
```dart
// lib/domain/models/coin.dart
class Coin {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double priceChange24H;
  final double priceChangePercentage24H;
  final double marketCapRank;
  final String imageUrl;
  final double volume24H;  // ← НОВОЕ ПОЛЕ
  
  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.priceChange24H,
    required this.priceChangePercentage24H,
    required this.marketCapRank,
    required this.imageUrl,
    required this.volume24H,  // ← НОВОЕ ПОЛЕ
  });
}
```

### Шаг 2: Isar модель в data
```dart
// lib/data/models/isar_coin_model.dart
@Collection()
class IsarCoin {
  Id? id;
  late String coinId;
  late String name;
  late String symbol;
  late double price;
  late double volume24H;  // ← НОВОЕ ПОЛЕ
  // ...
}
```

### Шаг 3: Парсинг в datasource
```dart
// lib/data/datasource/coin_remote_datasource_impl.dart
Coin _mapToCoin(dynamic json) {
  return Coin(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    symbol: json['symbol'] ?? '',
    price: (json['current_price'] ?? 0).toDouble(),
    volume24H: (json['total_volume'] ?? 0).toDouble(),  // ← НОВОЕ ПОЛЕ
    // ...
  );
}
```

---

## 2️⃣ Добавить новую страницу

### Шаг 1: Создать страницу
```dart
// lib/presentation/pages/new_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});
  
  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем данные при открытии
    _loadData();
  }

  void _loadData() {
    // context.read<MyCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Page')),
      body: Center(
        child: Text(
          'Your content here',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
```

### Шаг 2: Добавить в router
```dart
// lib/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ... существующие маршруты
    GoRoute(
      path: '/new-page',
      name: 'newPage',
      builder: (context, state) => const NewPage(),
    ),
  ],
);
```

### Шаг 3: Добавить навигацию
```dart
// Где-то в коде когда нужно перейти
context.push('/new-page');
```

---

## 3️⃣ Создать новый Cubit

### Шаг 1: Создать Cubit файл
```dart
// lib/presentation/pages/search_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final CoinRepo coinRepo;
  
  SearchCubit(this.coinRepo) : super(SearchInitial());

  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      // Получаем все монеты и фильтруем
      final allCoins = await coinRepo.getCoins();
      final filtered = allCoins
          .where((coin) =>
              coin.name.toLowerCase().contains(query.toLowerCase()) ||
              coin.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (filtered.isEmpty) {
        emit(SearchNoResults());
      } else {
        emit(SearchLoaded(filtered));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
```

### Шаг 2: Создать states файл
```dart
// lib/presentation/pages/search_state.dart
part of 'search_cubit.dart';

sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchLoaded extends SearchState {
  final List<Coin> coins;
  SearchLoaded(this.coins);
}

final class SearchNoResults extends SearchState {}

final class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
```

### Шаг 3: Использовать в UI
```dart
// В каком-то Widget'е
BlocProvider(
  create: (_) => SearchCubit(getIt<CoinRepo>()),
  child: SearchView(),
)
```

---

## 4️⃣ Вызвать API метод

### Способ 1: Через Repository
```dart
// lib/data/repository/coin_repository_impl.dart
@override
Future<List<Coin>> getCoins() async {
  try {
    // Удаленные данные
    final coins = await remoteDatasource.getCoins();
    // Сохраняем локально
    await localDatasource.saveCoinsList(coins);
    return coins;
  } catch (e) {
    // Если ошибка - берем из кеша
    return localDatasource.getCoinsList();
  }
}
```

### Способ 2: Из Cubit
```dart
// lib/presentation/pages/coin_cubit.dart
Future<void> loadCoins() async {
  emit(CoinLoading());
  try {
    final coins = await coinRepo.getCoins();
    emit(CoinLoaded(coins));
  } catch (e) {
    emit(CoinError(e.toString()));
  }
}
```

### Способ 3: Вызов в UI
```dart
// В Widget'е
@override
void initState() {
  super.initState();
  context.read<CoinCubit>().loadCoins();
}
```

---

## 5️⃣ Обновить данные в Supabase

```dart
// lib/presentation/pages/portfolio_cubit.dart
Future<void> updateAssetAmount(String itemId, double newAmount) async {
  if (_currentUserEmail == null) return;

  emit(PortfolioLoading());
  try {
    // Обновляем на сервере
    await portfolioRepository.updatePortfolioItemAmount(
      _currentUserEmail!,
      itemId,
      newAmount,
    );
    
    // Перезагружаем чтобы UI обновился
    await loadPortfolio(_currentUserEmail!);
  } catch (e) {
    emit(PortfolioError('Failed to update asset: ${e.toString()}'));
  }
}
```

```dart
// lib/data/datasource/portfolio_remote_datasource_impl.dart
@override
Future<void> updatePortfolioItemAmount(
  String userEmail,
  String itemId,
  double newAmount,
) async {
  try {
    await supabase
        .from('portfolios')
        .update({'amount': newAmount})
        .eq('user_email', userEmail)
        .eq('symbol', itemId);
  } catch (e) {
    throw Exception('Failed to update portfolio item: $e');
  }
}
```

---

## 6️⃣ Показать SnackBar с сообщением

```dart
// Способ 1: Простое сообщение
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Saved successfully')),
);

// Способ 2: С цветом и длительностью
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Error occurred'),
    backgroundColor: Colors.red.shade400,
    duration: const Duration(seconds: 3),
  ),
);

// Способ 3: После операции
await context.read<PortfolioCubit>().addAsset(symbol, amount);
if (context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$symbol added to portfolio')),
  );
}
```

---

## 7️⃣ Dialog/AlertDialog

```dart
// Подтверждение удаления
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Delete?'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          context.read<PortfolioCubit>().removeAsset(itemId);
          Navigator.pop(context);
        },
        child: const Text('Delete'),
      ),
    ],
  ),
);
```

---

## 8️⃣ BlocListener для побочных эффектов

```dart
// Когда нужно что-то сделать при изменении состояния
// (например, навигация, снэкбар)
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      context.go('/');  // Переходим на главную
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: Scaffold(
    // UI здесь
  ),
);
```

---

## 9️⃣ BlocBuilder для отображения разных состояний

```dart
BlocBuilder<PortfolioCubit, PortfolioState>(
  builder: (context, state) {
    if (state is PortfolioLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PortfolioLoaded) {
      return ListView(
        children: state.items.map((item) => ListTile(
          title: Text(item.symbol),
          subtitle: Text('${item.amount}'),
        )).toList(),
      );
    } else if (state is PortfolioError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const SizedBox();
  },
);
```

---

## 🔟 Тема - Адаптивные цвета

```dart
// Плохо - не адаптируется
Text('Hello', style: TextStyle(color: Colors.white));  // ❌

// Хорошо - использует тему
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyLarge,  // ✅
);

// Для вторичного текста
Color _getSecondaryTextColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
}

Text(
  'Secondary',
  style: TextStyle(color: _getSecondaryTextColor(context)),
);

// Цвет из схемы
Container(
  color: Theme.of(context).colorScheme.primary,
);

// Поверхность (фон)
Container(
  color: Theme.of(context).colorScheme.surface,
);
```

---

## 1️⃣1️⃣ ValueListenableBuilder (для реактивности)

```dart
// Обновляет UI при изменении TextEditingController
final controller = TextEditingController();

ValueListenableBuilder<TextEditingValue>(
  valueListenable: controller,
  builder: (context, value, child) {
    final amount = double.tryParse(value.text) ?? 0;
    final total = amount * coinPrice;
    
    return Text(
      '\$${total.toStringAsFixed(2)}',
      style: TextStyle(color: Colors.green.shade500),
    );
  },
);
```

---

## 1️⃣2️⃣ Регистрация нового сервиса в GetIt

```dart
// lib/di/service_locator.dart
void setupServiceLocator(Isar isar) {
  // Пример: регистрируем новый DataSource
  getIt.registerSingleton<MyNewDataSource>(
    MyNewDataSourceImpl(),
  );
  
  // Регистрируем Repository
  getIt.registerSingleton<MyNewRepository>(
    MyNewRepositoryImpl(
      dataSource: getIt<MyNewDataSource>(),
    ),
  );
}

// Использование в коде
final repo = getIt<MyNewRepository>();
```

---

Все эти примеры следуют паттернам, уже используемым в проекте!
