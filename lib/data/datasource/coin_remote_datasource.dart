import 'package:crypto_desctop/domain/models/coin.dart';

/// Abstract interface for remote coin data operations
abstract class CoinRemoteDatasource {
  /// Fetches a list of cryptocurrencies from the remote API
  Future<List<Coin>> getCoins();
}
