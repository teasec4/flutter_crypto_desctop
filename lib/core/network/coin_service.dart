import 'dart:isolate';

import 'package:crypto_desctop/core/isolate/worker_isolate.dart';
import 'package:crypto_desctop/domain/models/coin.dart';

/// Service for fetching cryptocurrency data using isolates for background processing
class CoinService {
  SendPort? _workerSendPort;

  /// Initializes the worker isolate for background coin fetching
  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;

    final receivePort = ReceivePort();
    await Isolate.spawn(coinWorker, receivePort.sendPort);
    _workerSendPort = await receivePort.first as SendPort;
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

    final rawList = await receivePort.first;

    if (rawList is Map && rawList.containsKey('error')) {
      throw Exception('Failed to fetch coins: ${rawList['error']}');
    }

    return (rawList as List).map((json) => Coin.fromJson(json)).toList();
  }
}
