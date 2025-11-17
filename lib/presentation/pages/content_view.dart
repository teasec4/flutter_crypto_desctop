import 'package:crypto_desctop/presentation/coin/coin_tile.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// View that displays a list of cryptocurrencies with pull-to-refresh and infinite scroll
class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detects when user scrolls near the bottom and loads more coins
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    // When user scrolls to 80% of the list, load more
    const threshold = 0.8;
    
    if (position.pixels > position.maxScrollExtent * threshold && !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<CoinCubit>().loadMoreCoins().then((_) {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: BlocBuilder<CoinCubit, CoinState>(
        builder: (context, state) {
          // Show loading spinner during initial load
          if (state is CoinInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show error message if initial load fails
          if (state is CoinError && state.previousCoins.isEmpty) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          // Handle CoinLoading state
          if (state is CoinLoading) {
            final coins = state.coins;
            
            // Initial loading (no coins yet)
            if (coins.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Loading more coins (append mode with indicator at bottom)
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<CoinCubit>().loadCoins();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: coins.length + 1,
                itemBuilder: (context, index) {
                  // Show loading indicator at the bottom
                  if (index == coins.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  final coin = coins[index];
                  return CoinTile(coin: coin);
                },
              ),
            );
          }
          
          // Handle CoinLoaded state
          if (state is CoinLoaded) {
            final coins = state.coins;
            
            if (coins.isEmpty) {
              return const Center(child: Text('No coins found'));
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<CoinCubit>().loadCoins();
              },
              child: ListView.builder(
                controller: _scrollController,
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
