import 'package:crypto_desctop/data/datasource/coin_local_datasource.dart';
import 'package:crypto_desctop/data/models/isar_coin_model.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:isar/isar.dart';

class CoinLocalDatasourceImpl implements CoinLocalDatasource {
  final Isar isar;

  CoinLocalDatasourceImpl(this.isar);

  @override
  Future<List<Coin>> getCachedCoins() async {
    try {
      final items = isar.isarCoins.where().findAllSync();
      return items.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheCoins(List<Coin> coins) async {
    final isarCoins = coins.map(IsarCoin.fromDomain).toList();
    await isar.writeTxn(() async {
      await isar.isarCoins.clear();
      await isar.isarCoins.putAll(isarCoins);
    });
  }

  @override
  Future<Coin?> getCachedCoin(String id) async {
    try {
      final cached = isar.isarCoins.filter().coinIdEqualTo(id).findFirstSync();
      return cached?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheCoin(Coin coin) async {
    await isar.writeTxn(() async {
      await isar.isarCoins.put(IsarCoin.fromDomain(coin));
    });
  }
}
