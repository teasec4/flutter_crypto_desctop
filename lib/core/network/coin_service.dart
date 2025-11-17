import 'dart:isolate';
import 'dart:developer' as developer;

import 'package:crypto_desctop/core/isolate/worker_isolate.dart';
import 'package:crypto_desctop/domain/models/coin.dart';

/// Service for fetching cryptocurrency data using isolates for background processing
class CoinService {
  SendPort? _workerSendPort;
  ReceivePort? _mainReceivePort;

  /// Initializes the worker isolate for background coin fetching
  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;

    final receivePort = ReceivePort();
    _mainReceivePort = receivePort;

    try {
      await Isolate.spawn(coinWorker, receivePort.sendPort);
      _workerSendPort = await receivePort.first as SendPort;
      developer.log('CoinService: Worker isolate initialized');
    } catch (e) {
      developer.log('CoinService: Failed to initialize worker isolate: $e');
      _mainReceivePort?.close();
      _mainReceivePort = null;
      rethrow;
    }
  }

  /// Fetches a list of coins from the CoinGecko API using an isolate
  Future<List<Coin>> getCoins() async {
    await _initializeWorker();

    final receivePort = ReceivePort();
    const perPage = 20;
    const page = 1;

    _workerSendPort!.send({
      'page': page,
      'perPage': perPage,
      'sendPort': receivePort.sendPort,
    });

    try {
      final rawList = await receivePort.first;

      if (rawList is Map && rawList.containsKey('error')) {
        throw Exception('Failed to fetch coins: ${rawList['error']}');
      }

      return (rawList as List).map((json) => Coin.fromJson(json)).toList();
    } finally {
      // Close the temporary response port
      receivePort.close();
    }
  }

  /// Cleanup resources - close the main receive port
  /// Call this when the service is no longer needed (e.g., on app exit)
  void dispose() {
    _mainReceivePort?.close();
    _mainReceivePort = null;
    _workerSendPort = null;
    developer.log('CoinService: Disposed');
  }
}
