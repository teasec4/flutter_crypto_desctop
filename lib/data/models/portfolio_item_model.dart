import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:isar/isar.dart';

part 'portfolio_item_model.g.dart';

@collection
class PortfolioItemModel {
  Id? id;

  late String symbol;
  late double amount;
  late DateTime addedAt;
  late String userEmail;

  PortfolioItemModel();

  // ------ Domain → Isar ------
  factory PortfolioItemModel.fromDomain(PortfolioItem item, String userEmail) {
    return PortfolioItemModel()
      ..symbol = item.symbol
      ..amount = item.amount
      ..addedAt = item.addedAt
      ..userEmail = userEmail;
  }

  // ------ Isar → Domain ------
  PortfolioItem toDomain() {
    return PortfolioItem(
      id: symbol.toLowerCase(),
      symbol: symbol,
      amount: amount,
      addedAt: addedAt,
    );
  }
}
