import 'package:crypto_desctop/di/service_locator.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/presentation/pages/coin_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailPage extends StatelessWidget {
  final String coinId;

  const CoinDetailPage({super.key, required this.coinId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoinDetailCubit(getIt<CoinRepo>())
          ..loadCoin(coinId),
      child: const CoinDetailView(),
    );
  }
}

class CoinDetailView extends StatelessWidget {
  const CoinDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<CoinDetailCubit, CoinDetailState>(
          builder: (context, state) {
            if (state is CoinDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CoinDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                  ],
                ),
              );
            } else if (state is CoinDetailLoaded) {
              final coin = state.coin;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              coin.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
        
                      // Coin image and basic info
                      Center(
                        child: Column(
                          children: [
                            Image.network(
                              coin.imageUrl,
                              width: 80,
                              height: 80,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error, size: 80),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              coin.symbol.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
        
                      // Price section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Price',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${coin.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // 24h change
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '24h Change',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${coin.priceChange24H.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: coin.priceChange24H >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '24h Change %',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${coin.priceChangePercentage24H.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: coin.priceChangePercentage24H >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // Market rank
                      if (coin.marketCapRank > 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Market Cap Rank',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '#${coin.marketCapRank}',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
