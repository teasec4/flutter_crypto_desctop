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
    // Cache-first strategy: try local first, then network

    // Try to get from cache first (especially important on app startup)
    if (page == 1) {
      final cachedCoins = await localDatasource.getCachedCoins();
      if (cachedCoins.isNotEmpty) {
        // Return cached data immediately and sync fresh data in background
        _syncCoinsInBackground(page, perPage);
        return cachedCoins;
      }
    }

    // If no cache, fetch from network
    try {
      final networkCoins = await remoteDatasource.getCoins(
        page: page,
        perPage: perPage,
      );
      // Cache only the first page
      if (page == 1) {
        await localDatasource.cacheCoins(networkCoins);
      }
      return networkCoins;
    } catch (e) {
      // If network fails and we haven't returned cache yet, try once more
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

  /// Syncs coins from network in background
  Future<void> _syncCoinsInBackground(int page, int perPage) async {
    try {
      final networkCoins = await remoteDatasource.getCoins(
        page: page,
        perPage: perPage,
      );
      if (page == 1) {
        await localDatasource.cacheCoins(networkCoins);
      }
    } catch (e) {
      // Silent fail - user sees cached data
    }
  }

  /// Force refresh from network, ignoring cache
  @override
  Future<List<Coin>> getCoinsFresh({int page = 1, int perPage = 100}) async {
    try {
      final networkCoins = await remoteDatasource.getCoins(
        page: page,
        perPage: perPage,
      );
      // Cache only the first page
      if (page == 1) {
        await localDatasource.cacheCoins(networkCoins);
      }
      return networkCoins;
    } catch (e) {
      // If fresh fetch fails, fall back to cache
      if (page == 1) {
        final cachedCoins = await localDatasource.getCachedCoins();
        if (cachedCoins.isNotEmpty) {
          return cachedCoins;
        }
      }
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
