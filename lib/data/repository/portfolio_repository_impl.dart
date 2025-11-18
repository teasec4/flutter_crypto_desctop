import 'dart:developer' as developer;
import 'package:crypto_desctop/data/datasource/portfolio_local_datasource.dart';
import 'package:crypto_desctop/data/datasource/portfolio_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/domain/repository/portfolio_repo.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;
  final PortfolioLocalDataSource localDataSource;

  PortfolioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail) async {
    // Cache-first strategy: try local first, then network
    try {
      final cachedItems = await localDataSource.getPortfolioItems(userEmail);
      if (cachedItems.isNotEmpty) {
        developer.log(
          'PortfolioRepository: Returning ${cachedItems.length} items from cache',
        );
        // Fetch fresh data in background (don't await, let it sync silently)
        _fetchAndCachePortfolioItems(userEmail);
        return cachedItems;
      }
    } catch (e) {
      developer.log('PortfolioRepository: Cache load failed - $e');
    }

    // If no cache, fetch from network
    try {
      final remoteItems = await remoteDataSource.getPortfolioItems(userEmail);
      // Cache the items
      await localDataSource.cachePortfolioItems(userEmail, remoteItems);
      return remoteItems;
    } catch (e) {
      developer.log('PortfolioRepository: Network load failed - $e');
      // Try cache as fallback
      try {
        final cachedItems = await localDataSource.getPortfolioItems(userEmail);
        if (cachedItems.isNotEmpty) {
          developer.log(
            'PortfolioRepository: Returning cached items as fallback',
          );
          return cachedItems;
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Force refresh from network, ignoring cache
  @override
  Future<List<PortfolioItem>> getPortfolioItemsFresh(String userEmail) async {
    try {
      developer.log('PortfolioRepository: Force fetch from network');
      final remoteItems = await remoteDataSource.getPortfolioItems(userEmail);
      // Update cache with fresh data
      await localDataSource.cachePortfolioItems(userEmail, remoteItems);
      developer.log('PortfolioRepository: Fresh items cached');
      return remoteItems;
    } catch (e) {
      developer.log('PortfolioRepository: Fresh fetch failed - $e');
      // Try cache as fallback
      try {
        final cachedItems = await localDataSource.getPortfolioItems(userEmail);
        if (cachedItems.isNotEmpty) {
          developer.log(
            'PortfolioRepository: Returning cached items as fallback',
          );
          return cachedItems;
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Fetch portfolio items from network and cache them in background
  Future<void> _fetchAndCachePortfolioItems(String userEmail) async {
    try {
      final remoteItems = await remoteDataSource.getPortfolioItems(userEmail);
      await localDataSource.cachePortfolioItems(userEmail, remoteItems);
      developer.log('PortfolioRepository: Background sync completed');
    } catch (e) {
      developer.log('PortfolioRepository: Background sync failed - $e');
    }
  }

  @override
  Future<void> addPortfolioItem(String userEmail, PortfolioItem item) async {
    await remoteDataSource.addPortfolioItem(userEmail, item);
    // Clear cache to force refresh on next load
    await localDataSource.clearPortfolioItems(userEmail);
  }

  @override
  Future<void> updatePortfolioItemAmount(
    String userEmail,
    String itemId,
    double newAmount,
  ) async {
    await remoteDataSource.updatePortfolioItemAmount(
      userEmail,
      itemId,
      newAmount,
    );
    // Clear cache to force refresh on next load
    await localDataSource.clearPortfolioItems(userEmail);
  }

  @override
  Future<void> removePortfolioItem(String userEmail, String itemId) async {
    await remoteDataSource.removePortfolioItem(userEmail, itemId);
    // Clear cache to force refresh on next load
    await localDataSource.clearPortfolioItems(userEmail);
  }
}
