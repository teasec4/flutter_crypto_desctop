part of 'coin_detail_cubit.dart';

sealed class CoinDetailState {}

class CoinDetailLoading extends CoinDetailState{}

class CoinDetailLoaded extends CoinDetailState{
  final Coin coin;
  CoinDetailLoaded(this.coin);
}

class CoinDetailError extends CoinDetailState {
  final String message;
  CoinDetailError(this.message);
}


