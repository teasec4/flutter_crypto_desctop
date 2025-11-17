import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/models/coin_chart_data.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

part 'coin_detail_state.dart';

/// Cubit for managing individual coin detail view
/// Fetches and manages state for a single cryptocurrency
class CoinDetailCubit extends Cubit<CoinDetailState> {
  final CoinRepo coinRepo;
  CoinDetailCubit(this.coinRepo) : super(CoinDetailLoading());

  /// Loads detailed information for a specific coin by ID including chart data
  Future<void> loadCoin(String coinId, {int chartDays = 30}) async {
    try {
      emit(CoinDetailLoading());

      // Load coin and chart data in parallel
      final coinFuture = coinRepo.getCoin(coinId);
      final chartFuture = coinRepo.getCoinChartData(coinId, days: chartDays);

      final results = await Future.wait([coinFuture, chartFuture]);
      final coin = results[0] as Coin;
      final chartData = results[1];

      emit(CoinDetailLoaded(coin, chartData: chartData as dynamic));
    } catch (e) {
      emit(CoinDetailError(e.toString()));
    }
  }
}
