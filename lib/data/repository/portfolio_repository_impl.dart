import 'package:crypto_desctop/data/datasource/portfolio_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/domain/repository/portfolio_repo.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;

  PortfolioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail) {
    return remoteDataSource.getPortfolioItems(userEmail);
  }

  @override
  Future<void> addPortfolioItem(String userEmail, PortfolioItem item) {
    return remoteDataSource.addPortfolioItem(userEmail, item);
  }

  @override
  Future<void> updatePortfolioItemAmount(
    String userEmail,
    String itemId,
    double newAmount,
  ) {
    return remoteDataSource.updatePortfolioItemAmount(
      userEmail,
      itemId,
      newAmount,
    );
  }

  @override
  Future<void> removePortfolioItem(String userEmail, String itemId) {
    return remoteDataSource.removePortfolioItem(userEmail, itemId);
  }

  @override
  Future<void> clearUserPortfolio(String userEmail) {
    return remoteDataSource.clearUserPortfolio(userEmail);
  }
}
