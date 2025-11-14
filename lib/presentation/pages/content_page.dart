import 'package:crypto_desctop/core/network/coin_service.dart';
import 'package:crypto_desctop/data/repository/coin_repository_impl.dart';
import 'package:crypto_desctop/main.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:crypto_desctop/presentation/pages/content_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coinRepo = CoinRepositoryImpl(
      coinService: CoinService(),
      isar: isarDb,
    );

    return BlocProvider(
      create: (context) => CoinCubit(coinRepo)..loadCoins(),
      child: const ContentView(),
    );
  }
}
