import 'package:crypto_desctop/domain/models/portfolio_item.dart';

abstract class PortfolioRepository {
  /// Получить все portfolio items пользователя по email
  /// Uses cache-first strategy: returns cached data immediately and syncs fresh data in background
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail);

  /// Force refresh from network, bypassing cache
  /// Used for manual refresh (pull-to-refresh gestures)
  Future<List<PortfolioItem>> getPortfolioItemsFresh(String userEmail);

  /// Добавить asset в portfolio
  Future<void> addPortfolioItem(String userEmail, PortfolioItem item);

  /// Обновить amount в portfolio item
  Future<void> updatePortfolioItemAmount(
    String userEmail,
    String itemId,
    double newAmount,
  );

  /// Удалить asset из portfolio
  Future<void> removePortfolioItem(String userEmail, String itemId);
}
