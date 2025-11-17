import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/models/coin_chart_data.dart';

/// Abstract interface for coin data repository
abstract class CoinRepo {
  /// Fetches a list of cryptocurrencies with pagination support
  /// Uses cache-first strategy: returns cached data immediately and syncs fresh data in background
  /// [page] - page number for pagination (starts at 1)
  /// [perPage] - number of coins per page (max 100)
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100});

  /// Force refresh from network, bypassing cache
  /// Used for manual refresh (pull-to-refresh gestures)
  /// [page] - page number for pagination (starts at 1)
  /// [perPage] - number of coins per page (max 100)
  Future<List<Coin>> getCoinsFresh({int page = 1, int perPage = 100});

  /// Fetches detailed information for a specific coin by ID
  Future<Coin> getCoin(String id);

  /// Fetches historical price data for chart visualization
  /// [coinId] - the CoinGecko coin ID
  /// [days] - number of days of history (1, 7, 30, 90, 365, max)
  Future<CoinChartData> getCoinChartData(String coinId, {int days = 30});
}
