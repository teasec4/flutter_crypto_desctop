import 'package:crypto_desctop/di/service_locator.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:crypto_desctop/presentation/pages/content_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page that displays the cryptocurrency market list
/// Handles Bloc initialization and provides the content view
class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coinRepo = getIt<CoinRepo>();

    return BlocProvider(
      // Initialize CoinCubit with repository and load coins immediately
      create: (context) => CoinCubit(coinRepo)..loadCoins(),
      child: const ContentView(),
    );
  }
}
