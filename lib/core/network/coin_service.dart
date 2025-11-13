import 'dart:isolate';

import 'package:crypto_desctop/core/isolate/worker_isolate.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

class CoinService implements CoinRepo {
  SendPort? _workerSendPort;

  Future<void> _initializeWorker() async {
    if (_workerSendPort != null) return;

    final receivePort = ReceivePort();
    await Isolate.spawn(coinWorker, receivePort.sendPort);
    _workerSendPort = await receivePort.first as SendPort;
  }

  @override
  Future<List<Coin>> getCoins() async {
    await _initializeWorker();

    final receivePort = ReceivePort();
    final perPage = 20;
    final page = 1;

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

  @override
  Future<Coin> getCoin(String id) {
    // TODO: implement getCoin
    throw UnimplementedError();
  }
}