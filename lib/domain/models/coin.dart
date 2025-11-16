import 'package:crypto_desctop/core/utils/type_converters.dart';

/// Represents a cryptocurrency coin with market data
class Coin {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final String imageUrl;
  final int marketCapRank;
  final double priceChange24H;
  final double priceChangePercentage24H;

  const Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.imageUrl,
    required this.marketCapRank,
    required this.priceChange24H,
    required this.priceChangePercentage24H,
  });

  /// Creates a Coin instance from JSON data (CoinGecko API format)
  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      price: TypeConverters.toDouble(json['current_price']),
      imageUrl: json['image'] as String? ?? '',
      marketCapRank: TypeConverters.toInt(json['market_cap_rank']),
      priceChange24H: TypeConverters.toDouble(json['price_change_24h']),
      priceChangePercentage24H: TypeConverters.toDouble(
        json['price_change_percentage_24h'],
      ),
    );
  }

  /// Converts Coin instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'price': price,
      'imageUrl': imageUrl,
      'marketCapRank': marketCapRank,
      'priceChange24H': priceChange24H,
      'priceChangePercentage24H': priceChangePercentage24H,
    };
  }
}
