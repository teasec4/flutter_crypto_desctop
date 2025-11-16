import 'package:crypto_desctop/domain/models/coin.dart';

/// Abstract interface for coin data repository
abstract class CoinRepo {
  /// Fetches a list of cryptocurrencies
  Future<List<Coin>> getCoins();

  /// Fetches detailed information for a specific coin by ID
  Future<Coin> getCoin(String id);
}
