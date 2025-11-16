import 'package:crypto_desctop/domain/models/portfolio_item.dart';

abstract class PortfolioRepository {
  /// Получить все portfolio items пользователя по email
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail);

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

  /// Удалить все assets пользователя (при logout)
  Future<void> clearUserPortfolio(String userEmail);
}
