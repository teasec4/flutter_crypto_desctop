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

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      price: _toDouble(json['current_price']),
      imageUrl: json['image'] as String? ?? '',
      marketCapRank: _toInt(json['market_cap_rank']),
      priceChange24H: _toDouble(json['price_change_24h']),
      priceChangePercentage24H: _toDouble(json['price_change_percentage_24h']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

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


