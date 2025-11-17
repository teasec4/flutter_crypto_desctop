import 'package:crypto_desctop/data/datasource/coin_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

/// Repository implementation for coin data using cache-first strategy
/// Coordinates between local (Isar) and remote (API) data sources
class CoinRepositoryImpl implements CoinRepo {
  final CoinRemoteDatasource remoteDatasource;
  final CoinLocalDatasource localDatasource;

  CoinRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100}) async {
    // For pagination, only cache page 1 for initial load optimization
    // Subsequent pages are fetched fresh
    
    // Then fetch from network
    try {
      final networkCoins = await remoteDatasource.getCoins(page: page, perPage: perPage);
      // Cache only the first page
      if (page == 1) {
        await localDatasource.cacheCoins(networkCoins);
      }
      return networkCoins;
    } catch (e) {
      // If it's page 1 and network fails, return cached data if available
      if (page == 1) {
        final cachedCoins = await localDatasource.getCachedCoins();
        if (cachedCoins.isNotEmpty) {
          return cachedCoins;
        }
      }
      // If no cache available or not page 1, propagate the error
      rethrow;
    }
  }

  @override
  Future<Coin> getCoin(String id) async {
    // First, try to load cached coin if it exists
    final cached = await localDatasource.getCachedCoin(id);
    if (cached != null) {
      return cached;
    }

    // If not cached, fetch from network (page 1 only, should be enough for most coins)
    try {
      final coins = await remoteDatasource.getCoins(page: 1, perPage: 100);
      final coin = coins.firstWhere((c) => c.id == id);
      // Cache the fresh data
      await localDatasource.cacheCoin(coin);
      return coin;
    } catch (e) {
      // If network fails and no cache, propagate the error
      rethrow;
    }
  }
}
