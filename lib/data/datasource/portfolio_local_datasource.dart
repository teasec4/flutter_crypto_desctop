import 'package:crypto_desctop/domain/models/portfolio_item.dart';

/// Abstract interface for local portfolio data persistence
abstract class PortfolioLocalDataSource {
  /// Get portfolio items from local cache for a specific user
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail);

  /// Cache portfolio items for a specific user
  Future<void> cachePortfolioItems(String userEmail, List<PortfolioItem> items);

  /// Clear portfolio cache for a specific user
  Future<void> clearPortfolioItems(String userEmail);
}
