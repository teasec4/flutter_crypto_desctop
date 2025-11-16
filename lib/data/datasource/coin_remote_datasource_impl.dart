import 'dart:isolate';
import 'package:crypto_desctop/core/isolate/worker_isolate.dart';
import 'package:crypto_desctop/data/datasource/coin_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/coin.dart';

class CoinRemoteDatasourceImpl implements CoinRemoteDatasource {
  // from main to worker
  SendPort? _workerSendPort;

  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;
    // recive port of main Isolate
    final receivePort = ReceivePort();
    // create a coinWorker and send receivePort
    await Isolate.spawn(coinWorker, receivePort.sendPort);
    _workerSendPort = await receivePort.first as SendPort;
  }

  @override
  Future<List<Coin>> getCoins() async {
    await _initializeWorker();

    final receivePort = ReceivePort();
    _workerSendPort!.send({
      'page': 1,
      'perPage': 20,
      'sendPort': receivePort.sendPort,
    });

    final rawList = await receivePort.first;

    if (rawList is Map && rawList.containsKey('error')) {
      throw Exception('Failed to fetch coins: ${rawList['error']}');
    }

    return (rawList as List).map((json) => Coin.fromJson(json)).toList();
  }

  @override
  Future<Coin> getCoin(String id) {
    throw UnimplementedError();
  }
}
