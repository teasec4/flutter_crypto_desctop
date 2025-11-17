import 'package:crypto_desctop/domain/models/coin.dart';

/// Abstract interface for coin data repository
abstract class CoinRepo {
  /// Fetches a list of cryptocurrencies with pagination support
  /// [page] - page number for pagination (starts at 1)
  /// [perPage] - number of coins per page (max 100)
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100});

  /// Fetches detailed information for a specific coin by ID
  Future<Coin> getCoin(String id);
}
