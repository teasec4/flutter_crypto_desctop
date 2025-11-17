import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crypto_desctop/domain/models/coin_chart_data.dart';

/// Widget that displays a line chart for coin price history
class CoinChartWidget extends StatefulWidget {
  final CoinChartData chartData;
  final int selectedDays;
  final Function(int) onDaysChanged;

  const CoinChartWidget({
    super.key,
    required this.chartData,
    this.selectedDays = 30,
    required this.onDaysChanged,
  });

  @override
  State<CoinChartWidget> createState() => _CoinChartWidgetState();
}

class _CoinChartWidgetState extends State<CoinChartWidget> {
  @override
  Widget build(BuildContext context) {
    final chartData = widget.chartData;

    if (!chartData.hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'No chart data available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }

    final isPositive = chartData.changePercentage >= 0;
    final lineColor = isPositive ? Colors.green.shade500 : Colors.red.shade400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and change percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Price Chart', style: Theme.of(context).textTheme.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${chartData.changePercentage.toStringAsFixed(2)}%',
                style: TextStyle(color: lineColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Time range selector
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TimeButton(
                label: '1D',
                days: 1,
                isSelected: widget.selectedDays == 1,
                onPressed: () => widget.onDaysChanged(1),
              ),
              const SizedBox(width: 8),
              _TimeButton(
                label: '7D',
                days: 7,
                isSelected: widget.selectedDays == 7,
                onPressed: () => widget.onDaysChanged(7),
              ),
              const SizedBox(width: 8),
              _TimeButton(
                label: '30D',
                days: 30,
                isSelected: widget.selectedDays == 30,
                onPressed: () => widget.onDaysChanged(30),
              ),
              const SizedBox(width: 8),
              _TimeButton(
                label: '90D',
                days: 90,
                isSelected: widget.selectedDays == 90,
                onPressed: () => widget.onDaysChanged(90),
              ),
              const SizedBox(width: 8),
              _TimeButton(
                label: '1Y',
                days: 365,
                isSelected: widget.selectedDays == 365,
                onPressed: () => widget.onDaysChanged(365),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Chart
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval:
                    (chartData.maxPrice - chartData.minPrice) / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 5 == 0) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.dataPoints.length) {
                          final date = chartData.dataPoints[index].timestamp;
                          return Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (chartData.dataPoints.length - 1).toDouble(),
              minY: chartData.minPrice * 0.95,
              maxY: chartData.maxPrice * 1.05,
              lineBarsData: [
                LineChartBarData(
                  spots: _generateSpots(chartData),
                  isCurved: true,
                  color: lineColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Min/Max prices
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '\$${chartData.minPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Current', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '\$${chartData.currentPrice.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('High', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '\$${chartData.maxPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Generates FlSpot list from chart data points
  List<FlSpot> _generateSpots(CoinChartData chartData) {
    return List.generate(
      chartData.dataPoints.length,
      (index) => FlSpot(index.toDouble(), chartData.dataPoints[index].price),
    );
  }
}

/// Time period button for chart time range selection
class _TimeButton extends StatelessWidget {
  final String label;
  final int days;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TimeButton({
    required this.label,
    required this.days,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(label),
    );
  }
}
