/// Represents a single data point on the coin price chart
class ChartDataPoint {
  final DateTime timestamp;
  final double price;

  const ChartDataPoint({required this.timestamp, required this.price});

  factory ChartDataPoint.fromList(List<dynamic> data) {
    return ChartDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(data[0].toInt()),
      price: (data[1] as num).toDouble(),
    );
  }
}

/// Represents historical price data for a coin over a period
class CoinChartData {
  final String coinId;
  final List<ChartDataPoint> dataPoints;
  final double minPrice;
  final double maxPrice;
  final double currentPrice;

  CoinChartData({
    required this.coinId,
    required this.dataPoints,
    required this.minPrice,
    required this.maxPrice,
    required this.currentPrice,
  });

  /// Returns true if there is chart data available
  bool get hasData => dataPoints.isNotEmpty;

  /// Returns the percentage change from start to end
  double get changePercentage {
    if (dataPoints.isEmpty) return 0;
    final first = dataPoints.first.price;
    final last = dataPoints.last.price;
    if (first == 0) return 0;
    return ((last - first) / first) * 100;
  }
}
