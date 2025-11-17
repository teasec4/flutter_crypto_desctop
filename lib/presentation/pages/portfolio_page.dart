import 'package:crypto_desctop/core/utils/ui_utils.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the user's cryptocurrency portfolio with holdings and total value
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PortfolioLoaded) {
          // Handle empty portfolio safely
          if (state.items.isEmpty) {
            return _buildEmptyPortfolio(context);
          }

          // Calculate total portfolio value
          double totalValue = 0;
          for (var item in state.items) {
            // Validate item data
            if (item.totalValue.isNaN || item.totalValue.isInfinite) {
              continue;
            }
            totalValue += item.totalValue;
          }

          // Validate total value
          if (totalValue.isNaN || totalValue.isInfinite) {
            totalValue = 0;
          }

          return RefreshIndicator(
           onRefresh: () => context.read<PortfolioCubit>().refreshPortfolio(),
           child: Column(
             children: [
               // Total portfolio value header card
               Padding(
                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                 child: Container(
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                         Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(
                       color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                     ),
                   ),
                   padding: const EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Portfolio Balance',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                       const SizedBox(height: 12),
                       Text(
                         '\$${totalValue.toStringAsFixed(2)}',
                         style: Theme.of(context).textTheme.displaySmall?.copyWith(
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       const SizedBox(height: 12),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.green.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                           '${state.items.length} assets',
                           style: Theme.of(context).textTheme.labelSmall?.copyWith(
                             color: Colors.green.shade500,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               // Portfolio items list
               Expanded(
                 child: ListView.builder(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   itemCount: state.items.length,
                   itemBuilder: (context, index) {
                     // Safely access items with bounds checking
                     if (index >= state.items.length) {
                       return const SizedBox();
                     }
                     final item = state.items[index];
                     // Validate item before building
                     if (_isValidPortfolioItem(item)) {
                       return _buildPortfolioTile(context, item, totalValue);
                     }
                     return const SizedBox();
                   },
                 ),
               ),
             ],
           ),
          );
        } else if (state is PortfolioError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<PortfolioCubit>().refreshPortfolio(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  /// Builds a tile widget for a single portfolio item
  Widget _buildPortfolioTile(BuildContext context, PortfolioItem item, double totalValue) {
    final percentage = totalValue > 0 ? (item.totalValue / totalValue * 100) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Cryptocurrency icon
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.currency_bitcoin, size: 24),
                  )
                : const Icon(Icons.currency_bitcoin, size: 24),
          ),
          // Coin symbol
          title: Text(
            item.symbol,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          // Coin name and amount held
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (item.name != null)
                Text(
                  item.name!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: UIUtils.getSecondaryTextColor(context),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${item.amount.toStringAsFixed(4)} ${item.symbol}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: UIUtils.getSecondaryTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Total value and percentage
          trailing: SizedBox(
            width: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Total holding value
                Text(
                  '\$${item.totalValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                // Percentage of portfolio
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Long press to remove asset from portfolio
          onLongPress: () => _handleRemoveAsset(context, item.symbol),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog for removing an asset from portfolio
  void _handleRemoveAsset(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Asset?'),
        content: const Text('Are you sure you want to remove this asset?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PortfolioCubit>().removeAsset(itemId);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Validates portfolio item data for safe rendering
  bool _isValidPortfolioItem(PortfolioItem item) {
    // Check for null or empty symbol
    if (item.symbol.isEmpty) {
      return false;
    }

    // Check for invalid numeric values
    if (item.amount.isNaN ||
        item.amount.isInfinite ||
        item.amount < 0 ||
        item.currentPrice.isNaN ||
        item.currentPrice.isInfinite ||
        item.currentPrice < 0 ||
        item.totalValue.isNaN ||
        item.totalValue.isInfinite ||
        item.totalValue < 0) {
      return false;
    }

    return true;
  }

  /// Builds empty portfolio view with helpful message
  Widget _buildEmptyPortfolio(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<PortfolioCubit>().refreshPortfolio(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wallet_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your portfolio is empty',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add coins from the home page to build your portfolio',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
