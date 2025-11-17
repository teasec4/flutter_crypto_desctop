import 'package:crypto_desctop/domain/models/coin.dart';

/// Abstract interface for remote coin data operations
abstract class CoinRemoteDatasource {
  /// Fetches a list of cryptocurrencies from the remote API
  /// [page] - page number for pagination (starts at 1)
  /// [perPage] - number of coins per page (max 100)
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100});
}
