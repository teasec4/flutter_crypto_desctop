import 'package:crypto_desctop/domain/models/coin.dart';

// should Domain layer have a connection with a network??

abstract class CoinRepo{
  // get a list of coins
  Future<List<Coin>> getCoins();
  // get one coin
  Future<Coin> getCoin(String id);
}