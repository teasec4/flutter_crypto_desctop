import 'dart:async';
import 'dart:convert';

import 'package:crypto_desctop/core/constants/app_constants.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/models/coin_chart_data.dart';
import 'package:http/http.dart' as http;

/// Implementation of CoinRemoteDatasource using direct HTTP requests
class CoinRemoteDatasourceImpl implements CoinRemoteDatasource {
  static const Duration _timeout = Duration(seconds: 15);

  @override
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100}) async {
    try {
      final url = Uri.parse(
        '${AppConstants.coinGeckoBaseUrl}${AppConstants.coinGeckoMarketsEndpoint}'
        '?vs_currency=usd&order=market_cap_desc'
        '&per_page=$perPage&page=$page&sparkline=false',
      );

      final response = await http
          .get(url)
          .timeout(_timeout, onTimeout: () => throw TimeoutException(
                'Request timeout after ${_timeout.inSeconds}s',
              ));

      if (response.statusCode == 200) {
        final rawList = json.decode(response.body) as List;
        return rawList.map((json) => Coin.fromJson(json)).toList();
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch coins: $e');
    }
  }

  @override
  Future<CoinChartData> getCoinChartData(String coinId, {int days = 30}) async {
    try {
      final url = Uri.parse(
        '${AppConstants.coinGeckoBaseUrl}${AppConstants.coinGeckoChartEndpoint.replaceFirst('{id}', coinId)}'
        '?vs_currency=usd&days=$days&interval=daily',
      );

      final response = await http
          .get(url)
          .timeout(_timeout, onTimeout: () => throw TimeoutException(
                'Request timeout after ${_timeout.inSeconds}s',
              ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Parse the prices array and extract data points
        final prices = (data['prices'] as List).cast<List>();
        final dataPoints = prices
            .map((price) => ChartDataPoint.fromList(price))
            .toList();

        // Calculate min and max prices
        double minPrice = double.infinity;
        double maxPrice = double.negativeInfinity;

        for (final point in dataPoints) {
          if (point.price < minPrice) minPrice = point.price;
          if (point.price > maxPrice) maxPrice = point.price;
        }

        final currentPrice = dataPoints.isNotEmpty ? dataPoints.last.price : 0.0;

        return CoinChartData(
          coinId: coinId,
          dataPoints: dataPoints,
          minPrice: minPrice,
          maxPrice: maxPrice,
          currentPrice: currentPrice,
        );
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch chart data: $e');
    }
  }
}
