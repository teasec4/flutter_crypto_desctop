part of 'coin_detail_cubit.dart';

/// Base class for coin detail view states
sealed class CoinDetailState {}

/// Loading state while fetching coin details
class CoinDetailLoading extends CoinDetailState {}

/// State when coin details have been successfully loaded
class CoinDetailLoaded extends CoinDetailState {
  final Coin coin;
  final CoinChartData? chartData;

  CoinDetailLoaded(this.coin, {this.chartData});
}

/// State indicating an error occurred while loading coin details
class CoinDetailError extends CoinDetailState {
  final String message;
  final String? coinId;

  CoinDetailError(this.message, {this.coinId});
}
