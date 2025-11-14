import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';

part 'coin_detail_state.dart';

class CoinDetailCubit extends Cubit<CoinDetailState> {
  final CoinRepo coinRepo;
  CoinDetailCubit(this.coinRepo) : super(CoinDetailLoading());

  Future<void> loadCoin(String coinId) async{
    try{
      emit(CoinDetailLoading());
      final coin = await coinRepo.getCoin(coinId);
      emit(CoinDetailLoaded(coin));

    } catch (e){
      emit(CoinDetailError(e.toString()));
    }
  }
}
