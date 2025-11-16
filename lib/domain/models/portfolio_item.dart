import 'package:crypto_desctop/core/utils/type_converters.dart';

/// Represents a cryptocurrency holding in user's portfolio
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

  /// Calculates the total value of this holding in USD
  double get totalValue => amount * currentPrice;

  /// Creates a PortfolioItem from JSON data
  /// Handles both camelCase and snake_case keys for flexibility
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    final addedAtValue = json['addedAt'] ?? json['added_at'];

    return PortfolioItem(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      amount: TypeConverters.toDouble(json['amount']),
      addedAt: addedAtValue is DateTime
          ? addedAtValue
          : DateTime.tryParse(
                  addedAtValue is String
                      ? addedAtValue
                      : addedAtValue.toString(),
                ) ??
                DateTime.now(),
    );
  }

  /// Converts PortfolioItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'amount': amount,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this PortfolioItem with optional field overrides
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
