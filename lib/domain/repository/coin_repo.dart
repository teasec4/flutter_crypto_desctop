import 'package:crypto_desctop/domain/models/coin.dart';

abstract class CoinRepo{
  // get a list of coins
  Future<List<Coin>> getCoins();
  // get one coin
  Future<Coin> getCoin(String id);
}