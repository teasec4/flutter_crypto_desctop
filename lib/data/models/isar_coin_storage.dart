
import 'package:crypto_desctop/data/models/isar_coin_model.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:isar/isar.dart';

class IsarCoinStorage{
  final Isar isar;

  IsarCoinStorage(this.isar);

  Future<List<Coin>> getCachedCoins() async {
    final items = await isar.isarCoins.where().findAll();
    return items.map((e) => e.toDomain()).toList();
  }

  Future<void> cacheCoins(List<Coin> coins) async {
    final isarCoins = coins.map(IsarCoin.fromDomain).toList();

    await isar.writeTxn(() async {
      await isar.isarCoins.clear();
      await isar.isarCoins.putAll(isarCoins);
    });
  }
}