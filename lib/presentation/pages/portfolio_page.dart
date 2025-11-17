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
          // Calculate total portfolio value
          double totalValue = 0;
          for (var item in state.items) {
            totalValue += item.totalValue;
          }

          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<PortfolioCubit>().refreshPortfolio(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'No assets in portfolio. Add coins from the home page!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<PortfolioCubit>().refreshPortfolio(),
            child: Column(
              children: [
                // Total portfolio value header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Total Portfolio Value',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${totalValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
                // Portfolio items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _buildPortfolioTile(context, item);
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
  Widget _buildPortfolioTile(BuildContext context, PortfolioItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        // Cryptocurrency icon
        leading: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.currency_bitcoin, size: 40),
              )
            : const Icon(Icons.currency_bitcoin, size: 40),
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
              'Amount: ${item.amount.toStringAsFixed(4)} ${item.symbol}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: UIUtils.getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Total value and current price
        trailing: SizedBox(
          width: 120,
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
              const SizedBox(height: 4),
              // Current price per coin
              Text(
                '\$${item.currentPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: UIUtils.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        // Long press to remove asset from portfolio
        onLongPress: () => _handleRemoveAsset(context, item.symbol),
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
}
