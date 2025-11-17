import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for coin list view states
sealed class CoinState {}

/// Initial state before coins are loaded
class CoinInitial extends CoinState {}

/// Loading state while fetching coins from the API
class CoinLoading extends CoinState {
  final List<Coin> coins;
  CoinLoading(this.coins);
}

/// State when coins have been successfully loaded
class CoinLoaded extends CoinState {
  final List<Coin> coins;
  final int currentPage;
  final bool hasMorePages;
  
  CoinLoaded({
    required this.coins,
    required this.currentPage,
    this.hasMorePages = true,
  });
}

/// State indicating an error occurred while loading coins
class CoinError extends CoinState {
  final String message;
  final List<Coin> previousCoins;
  
  CoinError(this.message, {this.previousCoins = const []});
}

/// Cubit for managing the cryptocurrency coins list with pagination
class CoinCubit extends Cubit<CoinState> {
  final CoinRepo coinRepo;
  static const int coinsPerPage = 100;

  CoinCubit(this.coinRepo) : super(CoinInitial());

  /// Fetches the first page of coins
  Future<void> loadCoins() async {
    try {
      emit(CoinLoading([]));
      final coinsList = await coinRepo.getCoins(page: 1, perPage: coinsPerPage);
      emit(CoinLoaded(
        coins: coinsList,
        currentPage: 1,
        hasMorePages: coinsList.length == coinsPerPage,
      ));
    } catch (e) {
      emit(CoinError(e.toString()));
    }
  }

  /// Loads the next page of coins and appends to existing list
  Future<void> loadMoreCoins() async {
    final currentState = state;
    if (currentState is! CoinLoaded) return;
    if (!currentState.hasMorePages) return;

    try {
      final nextPage = currentState.currentPage + 1;
      emit(CoinLoading(currentState.coins));
      
      final newCoins = await coinRepo.getCoins(
        page: nextPage,
        perPage: coinsPerPage,
      );

      final allCoins = [...currentState.coins, ...newCoins];
      emit(CoinLoaded(
        coins: allCoins,
        currentPage: nextPage,
        hasMorePages: newCoins.length == coinsPerPage,
      ));
    } catch (e) {
      emit(CoinError(e.toString(), previousCoins: currentState.coins));
    }
  }
}
