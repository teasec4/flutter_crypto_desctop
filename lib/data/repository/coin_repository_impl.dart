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
  Future<List<Coin>> getCoins() async {
    // First, try to get cached coins
    final cachedCoins = await localDatasource.getCachedCoins();

    // Then fetch from network to update cache
    try {
      final networkCoins = await remoteDatasource.getCoins();
      // Cache the fresh data
      await localDatasource.cacheCoins(networkCoins);
      return networkCoins;
    } catch (e) {
      // If network fails, return cached data if available
      if (cachedCoins.isNotEmpty) {
        return cachedCoins;
      }
      // If no cache available, propagate the error
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

    // If not cached, fetch from network
    try {
      final coin = await remoteDatasource.getCoins().then(
        (coins) => coins.firstWhere((c) => c.id == id),
      );
      // Cache the fresh data
      await localDatasource.cacheCoin(coin);
      return coin;
    } catch (e) {
      // If network fails and no cache, propagate the error
      rethrow;
    }
  }
}
