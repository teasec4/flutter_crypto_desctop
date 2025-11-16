import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for coin list view states
sealed class CoinState {}

/// Initial state before coins are loaded
class CoinInitial extends CoinState {}

/// Loading state while fetching coins from the API
class CoinLoading extends CoinState {}

/// State when coins have been successfully loaded
class CoinLoaded extends CoinState {
  final List<Coin> coins;
  CoinLoaded(this.coins);
}

/// State indicating an error occurred while loading coins
class CoinError extends CoinState {
  final String message;
  CoinError(this.message);
}

/// Cubit for managing the cryptocurrency coins list
/// Fetches coins from the repository and manages loading states
class CoinCubit extends Cubit<CoinState> {
  final CoinRepo coinRepo;

  CoinCubit(this.coinRepo) : super(CoinInitial());

  /// Fetches the list of cryptocurrencies from the repository
  Future<void> loadCoins() async {
    try {
      emit(CoinLoading());
      final coinsList = await coinRepo.getCoins();
      emit(CoinLoaded(coinsList));
    } catch (e) {
      emit(CoinError(e.toString()));
    }
  }
}
