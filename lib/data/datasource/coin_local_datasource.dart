import 'package:crypto_desctop/domain/models/coin.dart';

abstract class CoinLocalDatasource {
  Future<List<Coin>> getCachedCoins();
  Future<void> cacheCoins(List<Coin> coins);
  Future<Coin?> getCachedCoin(String id);
  Future<void> cacheCoin(Coin coin);
}
