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
      final int page = msg['page'];
      final int perPage = msg['perPage'];
      final SendPort responseSendPort = msg['sendPort'];

      final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets'
        '?vs_currency=usd&order=market_cap_desc'
        '&per_page=$perPage&page=$page&sparkline=false',
      );

      try {
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
  }
}
