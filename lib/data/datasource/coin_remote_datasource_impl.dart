import 'dart:isolate';
import 'package:crypto_desctop/core/isolate/worker_isolate.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/coin.dart';

/// Implementation of CoinRemoteDatasource using isolates for background processing
class CoinRemoteDatasourceImpl implements CoinRemoteDatasource {
  // Send port for communicating with the worker isolate
  SendPort? _workerSendPort;

  /// Initializes the worker isolate for background coin fetching
  /// Creates a one-way connection to avoid blocking the main thread
  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;
    // Create a receive port in the main isolate
    final receivePort = ReceivePort();
    // Spawn worker isolate and establish communication
    await Isolate.spawn(coinWorker, receivePort.sendPort);
    // Get the send port from the worker to send messages
    _workerSendPort = await receivePort.first as SendPort;
  }

  @override
  Future<List<Coin>> getCoins({int page = 1, int perPage = 100}) async {
    await _initializeWorker();

    final receivePort = ReceivePort();
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
