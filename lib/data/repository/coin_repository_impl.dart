import 'package:crypto_desctop/core/network/coin_service.dart';
import 'package:crypto_desctop/data/models/isar_coin_model.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:isar/isar.dart';

class CoinRepositoryImpl implements CoinRepo {
  final CoinService coinService;
  final Isar isar;

  CoinRepositoryImpl({required this.coinService, required this.isar});

  @override
  Future<List<Coin>> getCoins() async {
    // 1. Сразу вернуть из кеша (если есть)
    List<Coin> cachedCoins = [];
    try {
      final items = isar.isarCoins.where().findAllSync();
      cachedCoins = items.map((e) => e.toDomain()).toList();
    } catch (_) {
      // Если БД еще не инициализирована или пуста
    }

    // 2. Параллельно обновить с сети
    try {
      final networkCoins = await coinService.getCoins();
      
      // Сохранить в БД
      await isar.writeTxn(() async {
        await isar.isarCoins.clear();
        await isar.isarCoins.putAll(
          networkCoins.map((c) => IsarCoin.fromDomain(c)).toList(),
        );
      });
      
      return networkCoins;
    } catch (e) {
      // Если ошибка сети, вернуть кеш
      if (cachedCoins.isNotEmpty) {
        return cachedCoins;
      }
      rethrow; // Если кеша тоже нет, пробросить ошибку
    }
  }

  @override
  Future<Coin> getCoin(String id) async {
    // Аналогично для одной монеты
    try {
      final cached = isar.isarCoins.filter().coinIdEqualTo(id).findFirstSync();
      if (cached != null) {
        return cached.toDomain();
      }
    } catch (_) {}

    try {
      final coin = await coinService.getCoin(id);
      
      await isar.writeTxn(() async {
        await isar.isarCoins.put(IsarCoin.fromDomain(coin));
      });
      
      return coin;
    } catch (e) {
      rethrow;
    }
  }
}
