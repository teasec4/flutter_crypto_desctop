import 'package:crypto_desctop/presentation/coin/coin_tile.dart';
import 'package:crypto_desctop/presentation/pages/coin_search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that displays search results for coins
/// Adapts colors to both light and dark themes
class CoinSearchResults extends StatelessWidget {
  final ScrollController scrollController;

  const CoinSearchResults({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Define colors based on theme
    final emptyIconBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final emptyIconColor = colorScheme.primary.withValues(alpha: 0.6);
    final emptyTitleColor = colorScheme.onSurface;
    final emptyQueryColor = colorScheme.onSurface.withValues(alpha: 0.6);
    final emptyHintColor = colorScheme.onSurface.withValues(alpha: 0.5);
    final resultTitleColor = colorScheme.onSurface.withValues(alpha: 0.7);
    final queryHighlightColor = colorScheme.primary;

    return BlocBuilder<CoinSearchCubit, CoinSearchState>(
      builder: (context, state) {
        if (state is CoinSearchInitial) {
          return const SizedBox.shrink();
        }

        if (state is CoinSearchEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: emptyIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 56,
                    color: emptyIconColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No coins found',
                  style: TextStyle(
                    color: emptyTitleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for "${state.query}"',
                  style: TextStyle(color: emptyQueryColor, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  'Try searching by coin name or symbol',
                  style: TextStyle(color: emptyHintColor, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (state is CoinSearchResult || state is CoinSearching) {
          final results = (state is CoinSearchResult)
              ? state.results
              : (state as CoinSearching).results;
          final query = (state is CoinSearchResult)
              ? state.query
              : (state as CoinSearching).query;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'Results for',
                      style: TextStyle(
                        color: resultTitleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '"$query"',
                      style: TextStyle(
                        color: queryHighlightColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${results.length} coin${results.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final coin = results[index];
                    return CoinTile(coin: coin);
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
