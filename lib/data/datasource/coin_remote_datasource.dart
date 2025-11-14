import 'package:crypto_desctop/domain/models/coin.dart';

abstract class CoinRemoteDatasource {
  Future<List<Coin>> getCoins();
  Future<Coin> getCoin(String id);
}
