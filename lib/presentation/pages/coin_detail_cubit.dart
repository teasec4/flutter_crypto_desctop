import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

part 'coin_detail_state.dart';

/// Cubit for managing individual coin detail view
/// Fetches and manages state for a single cryptocurrency
class CoinDetailCubit extends Cubit<CoinDetailState> {
  final CoinRepo coinRepo;
  CoinDetailCubit(this.coinRepo) : super(CoinDetailLoading());

  /// Loads detailed information for a specific coin by ID
  Future<void> loadCoin(String coinId) async {
    try {
      emit(CoinDetailLoading());
      final coin = await coinRepo.getCoin(coinId);
      emit(CoinDetailLoaded(coin));
    } catch (e) {
      emit(CoinDetailError(e.toString()));
    }
  }
}
