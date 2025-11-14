import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:isar/isar.dart';
part 'isar_coin_model.g.dart';

@collection
class IsarCoin {
  Id id = Isar.autoIncrement;

  late String coinId;  // domain id
  late String name;
  late String symbol;
  late double price;
  late String imageUrl;
  late int marketCapRank;
  late double priceChange24H;
  late double priceChangePercentage24H;

  IsarCoin();

  // ------ Domain → Isar ------
  factory IsarCoin.fromDomain(Coin coin) {
    return IsarCoin()
      ..coinId = coin.id
      ..name = coin.name
      ..symbol = coin.symbol
      ..price = coin.price
      ..imageUrl = coin.imageUrl
      ..marketCapRank = coin.marketCapRank
      ..priceChange24H = coin.priceChange24H
      ..priceChangePercentage24H = coin.priceChangePercentage24H;
  }

  // ------ Isar → Domain ------
  Coin toDomain() {
    return Coin(
      id: coinId,
      name: name,
      symbol: symbol,
      price: price,
      imageUrl: imageUrl,
      marketCapRank: marketCapRank,
      priceChange24H: priceChange24H,
      priceChangePercentage24H: priceChangePercentage24H,
    );
  }

}