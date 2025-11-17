import 'dart:developer' as developer;
import 'package:crypto_desctop/data/datasource/portfolio_local_datasource.dart';
import 'package:crypto_desctop/data/models/portfolio_item_model.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:isar/isar.dart';

/// Implementation of portfolio local data persistence using Isar
class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  final Isar isar;

  PortfolioLocalDataSourceImpl(this.isar);

  @override
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail) async {
    try {
      final models = await isar.portfolioItemModels
          .filter()
          .userEmailEqualTo(userEmail)
          .findAll();

      developer.log(
        'PortfolioLocalDataSource: Found ${models.length} items for $userEmail in cache',
      );

      return models
          .map(
            (model) => PortfolioItem(
              id: model.symbol.toLowerCase(),
              symbol: model.symbol,
              amount: model.amount,
              addedAt: model.addedAt,
            ),
          )
          .toList();
    } catch (e) {
      developer.log(
        'PortfolioLocalDataSource: Error reading portfolio from cache - $e',
      );
      return [];
    }
  }

  @override
  Future<void> cachePortfolioItems(
    String userEmail,
    List<PortfolioItem> items,
  ) async {
    try {
      // Clear existing portfolio for this user
      await isar.writeTxn(() async {
        await isar.portfolioItemModels
            .filter()
            .userEmailEqualTo(userEmail)
            .deleteAll();
      });

      // Add new items
      final models = items.map((item) {
        final model = PortfolioItemModel();
        model.symbol = item.symbol;
        model.amount = item.amount;
        model.addedAt = item.addedAt;
        model.userEmail = userEmail;
        return model;
      }).toList();

      await isar.writeTxn(() async {
        await isar.portfolioItemModels.putAll(models);
      });

      developer.log(
        'PortfolioLocalDataSource: Cached ${models.length} items for $userEmail',
      );
    } catch (e) {
      developer.log('PortfolioLocalDataSource: Error caching portfolio - $e');
      rethrow;
    }
  }

  @override
  Future<void> clearPortfolioItems(String userEmail) async {
    try {
      await isar.writeTxn(() async {
        await isar.portfolioItemModels
            .filter()
            .userEmailEqualTo(userEmail)
            .deleteAll();
      });

      developer.log(
        'PortfolioLocalDataSource: Cleared portfolio for $userEmail',
      );
    } catch (e) {
      developer.log('PortfolioLocalDataSource: Error clearing portfolio - $e');
      rethrow;
    }
  }
}
