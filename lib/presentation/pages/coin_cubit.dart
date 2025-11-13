import 'package:crypto_desctop/core/network/coin_service.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
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
  final CoinService coinService;

  CoinCubit(this.coinService) : super(CoinInitial());

  Future<void> loadCoins() async {
    try {
      emit(CoinLoading());
      final coinsList = await coinService.getCoins();
      emit(CoinLoaded(coinsList));
    } catch (e) {
      emit(CoinError(e.toString()));
    }
  }
}