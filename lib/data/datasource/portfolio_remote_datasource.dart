import 'package:crypto_desctop/domain/models/portfolio_item.dart';

abstract class PortfolioRemoteDataSource {
  /// Получить все portfolio items пользователя из Firestore
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail);

  /// Добавить asset в Firestore portfolio
  Future<void> addPortfolioItem(String userEmail, PortfolioItem item);

  /// Обновить amount в Firestore portfolio item
  Future<void> updatePortfolioItemAmount(
    String userEmail,
    String itemId,
    double newAmount,
  );

  /// Удалить asset из Firestore portfolio
  Future<void> removePortfolioItem(String userEmail, String itemId);
}
