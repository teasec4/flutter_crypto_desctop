class PortfolioItem {
  final String id;
  final String symbol;
  final double amount;
  final DateTime addedAt;
  final double currentPrice;
  final String? imageUrl;
  final String? name;

  const PortfolioItem({
    required this.id,
    required this.symbol,
    required this.amount,
    required this.addedAt,
    this.currentPrice = 0.0,
    this.imageUrl,
    this.name,
  });

  /// Total value of this holding in USD
  double get totalValue => amount * currentPrice;

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case keys
    final addedAtValue = json['addedAt'] ?? json['added_at'];
    
    return PortfolioItem(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      amount: _toDouble(json['amount']),
      addedAt: addedAtValue is DateTime
          ? addedAtValue
          : DateTime.tryParse(addedAtValue is String ? addedAtValue : addedAtValue.toString()) ??
                DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'amount': amount,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  PortfolioItem copyWith({
    String? id,
    String? symbol,
    double? amount,
    DateTime? addedAt,
    double? currentPrice,
    String? imageUrl,
    String? name,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
      addedAt: addedAt ?? this.addedAt,
      currentPrice: currentPrice ?? this.currentPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
    );
  }
}
