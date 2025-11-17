import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/models/coin_chart_data.dart';

/// Abstract interface for remote coin data operations
abstract class CoinRemoteDatasource {
  /// Fetches a list of cryptocurrencies from the remote API
  /// [page] - page number for pagination (starts at 1)
  /// [perPage] - number of coins per page (max 100)
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100});

  /// Fetches historical price data for a coin
  /// [coinId] - the CoinGecko coin ID
  /// [days] - number of days of history (1, 7, 30, 90, 365, max)
  Future<CoinChartData> getCoinChartData(String coinId, {int days = 30});
}
