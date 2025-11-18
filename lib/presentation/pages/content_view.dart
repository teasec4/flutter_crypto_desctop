import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/presentation/coin/coin_tile.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:crypto_desctop/presentation/pages/coin_search_cubit.dart';
import 'package:crypto_desctop/presentation/widgets/coin_search_bar.dart';
import 'package:crypto_desctop/presentation/widgets/coin_search_results.dart';
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

    if (position.pixels > position.maxScrollExtent * threshold &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<CoinCubit>().loadMoreCoins().then((_) {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoinCubit, CoinState>(
      listener: (context, state) {
        // Show toast when coins are updated in background
        if (state is CoinUpdated) {
          // Update search cubit with new coins
          context.read<CoinSearchCubit>().updateCoins(state.coins);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Coin prices updated'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              backgroundColor: Colors.green.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<CoinCubit, CoinState>(
        builder: (context, coinState) {
          // Show loading spinner during initial load
          if (coinState is CoinInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if initial load fails
          if (coinState is CoinError && coinState.previousCoins.isEmpty) {
            return Center(child: Text('Error: ${coinState.message}'));
          }

          // Get coins from current state
          List<Coin> coins = [];
          if (coinState is CoinLoading) {
            coins = coinState.coins;
          } else if (coinState is CoinLoaded) {
            coins = coinState.coins;
          }

          // Initialize search cubit with all coins on first load
          if (coins.isNotEmpty) {
            context.read<CoinSearchCubit>().allCoins.clear();
            context.read<CoinSearchCubit>().allCoins.addAll(coins);
          }

          if (coins.isEmpty && coinState is CoinLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (coins.isEmpty) {
            return const Center(child: Text('No coins found'));
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: CoinSearchBar(
                  onChanged: (query) async {
                    await context.read<CoinSearchCubit>().search(query);
                  },
                  onClear: () {
                    context.read<CoinSearchCubit>().clearSearch();
                  },
                ),
              ),
              // Main content - either search results or full list
              Expanded(
                child: BlocBuilder<CoinSearchCubit, CoinSearchState>(
                  builder: (context, searchState) {
                    // If searching, show search results
                    if (searchState is! CoinSearchInitial) {
                      return CoinSearchResults(
                        scrollController: _scrollController,
                      );
                    }

                    // Otherwise show full list with refresh
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<CoinCubit>().refreshCoins();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            coins.length + (coinState is CoinLoading ? 1 : 0),
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
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
