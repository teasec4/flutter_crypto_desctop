import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

/// Timeout duration for network requests (10 seconds)
const Duration _networkTimeout = Duration(seconds: 10);

void coinWorker(SendPort mainSendPort) async {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);

  await for (final msg in workerReceivePort) {
    if (msg is Map<String, dynamic>) {
      final SendPort responseSendPort = msg['sendPort'];

      // Handle different request types
      if (msg.containsKey('page') && msg.containsKey('perPage')) {
        // Regular coin list request
        await _handleCoinListRequest(msg, responseSendPort);
      } else if (msg.containsKey('coinId') && msg.containsKey('days')) {
        // Chart data request
        await _handleChartDataRequest(msg, responseSendPort);
      } else {
        responseSendPort.send({'error': 'Unknown request type'});
      }
    }
  }
}

/// Handles coin list API request
Future<void> _handleCoinListRequest(
  Map<String, dynamic> msg,
  SendPort responseSendPort,
) async {
  try {
    final int page = msg['page'];
    final int perPage = msg['perPage'];

    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=usd&order=market_cap_desc'
      '&per_page=$perPage&page=$page&sparkline=false',
    );

    // Execute request with timeout for security
    final response = await http
        .get(url)
        .timeout(
          _networkTimeout,
          onTimeout: () => throw TimeoutException(
            'Network request timed out after ${_networkTimeout.inSeconds}s',
          ),
        );

    if (response.statusCode == 200) {
      final rawList = json.decode(response.body) as List;
      responseSendPort.send(rawList);
    } else {
      responseSendPort.send({
        'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      });
    }
  } catch (e) {
    responseSendPort.send({'error': e.toString()});
  }
}

/// Handles chart data API request
Future<void> _handleChartDataRequest(
  Map<String, dynamic> msg,
  SendPort responseSendPort,
) async {
  try {
    final String coinId = msg['coinId'];
    final int days = msg['days'];

    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$coinId/market_chart'
      '?vs_currency=usd&days=$days&interval=daily',
    );

    // Execute request with timeout for security
    final response = await http
        .get(url)
        .timeout(
          _networkTimeout,
          onTimeout: () => throw TimeoutException(
            'Network request timed out after ${_networkTimeout.inSeconds}s',
          ),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      responseSendPort.send(data);
    } else {
      responseSendPort.send({
        'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      });
    }
  } catch (e) {
    responseSendPort.send({'error': e.toString()});
  }
}
