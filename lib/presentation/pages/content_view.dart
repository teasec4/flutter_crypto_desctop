import 'package:crypto_desctop/presentation/coin/coin_tile.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: BlocBuilder<CoinCubit, CoinState>(
        builder: (context, state) {
          if (state is CoinInitial || state is CoinLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoinError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is CoinLoaded) {
            final coins = state.coins;
            if (coins.isEmpty) {
              return const Center(child: Text('No coins found'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<CoinCubit>().loadCoins();
              },
              child: ListView.builder(
                itemCount: coins.length,
                itemBuilder: (context, index) {
                  final coin = coins[index];
                  return CoinTile(coin: coin);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
