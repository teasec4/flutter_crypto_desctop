import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/presentation/pages/auth_cubit.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  void _loadPortfolioData() {
    final authCubit = context.read<AuthCubit>();
    final userEmail = authCubit.getCurrentUserEmail();

    if (userEmail != null) {
      context.read<PortfolioCubit>().loadPortfolio(userEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PortfolioLoaded) {
          // Calculate total value
          double totalValue = 0;
          for (var item in state.items) {
            totalValue += item.totalValue;
          }

          if (state.items.isEmpty) {
            return Center(
              child: Text(
                'No assets in portfolio. Add coins from the home page!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return Column(
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
          );
        } else if (state is PortfolioError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox();
      },
    );
  }

  Color _getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.grey.shade400;
    } else {
      return Colors.grey.shade700;
    }
  }

  Widget _buildPortfolioTile(
    BuildContext context,
    PortfolioItem item,
  ) {
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
        leading: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.currency_bitcoin, size: 40),
              )
            : const Icon(Icons.currency_bitcoin, size: 40),
        title: Text(
          item.symbol,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (item.name != null)
              Text(
                item.name!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
              ),
            const SizedBox(height: 4),
            Text(
              'Amount: ${item.amount.toStringAsFixed(4)} ${item.symbol}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getSecondaryTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.currentPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.totalValue.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade500,
                    ),
              ),
            ],
          ),
        ),
        onLongPress: () => _handleRemoveAsset(context, item.symbol),
      ),
    );
  }

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
