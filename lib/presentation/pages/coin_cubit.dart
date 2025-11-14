import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CoinState {}

class CoinInitial extends CoinState {}

class CoinLoading extends CoinState {}

class CoinLoaded extends CoinState {
  final List<Coin> coins;
  CoinLoaded(this.coins);
}

class CoinError extends CoinState {
  final String message;
  CoinError(this.message);
}

class CoinCubit extends Cubit<CoinState> {
  final CoinRepo coinRepo;

  CoinCubit(this.coinRepo) : super(CoinInitial());

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