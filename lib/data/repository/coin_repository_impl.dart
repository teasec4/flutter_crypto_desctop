import 'package:crypto_desctop/data/datasource/coin_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

/// Repository pattern: координирует работу локального и удаленного источников
class CoinRepositoryImpl implements CoinRepo {
  final CoinRemoteDatasource remoteDatasource;
  final CoinLocalDatasource localDatasource;

  CoinRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<List<Coin>> getCoins() async {
    // 1. cashe
    final cachedCoins = await localDatasource.getCachedCoins();

    // 2. update from network
    try {
      final networkCoins = await remoteDatasource.getCoins();
      await localDatasource.cacheCoins(networkCoins);
      return networkCoins;
    } catch (e) {
      // Если ошибка сети, вернуть кеш
      if (cachedCoins.isNotEmpty) {
        return cachedCoins;
      }
      rethrow;
    }
  }

  @override
  Future<Coin> getCoin(String id) async {
    // 1. load cashe if exist
    final cached = await localDatasource.getCachedCoin(id);
    if (cached != null) {
      return cached;
    }

    // 2. upload from network
    try {
      final coin = await remoteDatasource.getCoin(id);
      await localDatasource.cacheCoin(coin);
      return coin;
    } catch (e) {
      rethrow;
    }
  }
}
