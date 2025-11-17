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
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Balance',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '\$${totalValue.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${state.items.length} assets',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
  Widget _buildPortfolioTile(
    BuildContext context,
    PortfolioItem item,
    double totalValue,
  ) {
    final percentage = totalValue > 0
        ? (item.totalValue / totalValue * 100)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.15),
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          // Cryptocurrency icon
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
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
          // Tap to open edit/delete modal
          onTap: () => _showEditPortfolioModal(context, item),
        ),
      ),
    );
  }

  /// Shows a modal bottom sheet for editing or deleting a portfolio item
  void _showEditPortfolioModal(BuildContext context, PortfolioItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditPortfolioSheet(item: item),
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

/// Modal bottom sheet for editing or deleting a portfolio item
class _EditPortfolioSheet extends StatefulWidget {
  final PortfolioItem item;

  const _EditPortfolioSheet({required this.item});

  @override
  State<_EditPortfolioSheet> createState() => _EditPortfolioSheetState();
}

class _EditPortfolioSheetState extends State<_EditPortfolioSheet> {
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.item.amount.toStringAsFixed(4),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Handles updating the amount
  void _handleUpdateAmount() {
    if (_formKey.currentState?.validate() ?? false) {
      final newAmount = double.parse(_amountController.text);

      setState(() => _isLoading = true);

      final cubit = context.read<PortfolioCubit>();
      cubit
          .updateAssetAmount(widget.item.id, newAmount)
          .then((_) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.item.symbol} amount updated'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          })
          .onError((error, stackTrace) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${error.toString()}')),
              );
            }
          });
    }
  }

  /// Handles deleting the asset
  void _handleDeleteAsset() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Asset?'),
        content: Text(
          'Remove ${widget.item.symbol} from your portfolio? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              setState(() => _isLoading = true);

              final cubit = context.read<PortfolioCubit>();
              cubit
                  .removeAsset(widget.item.id)
                  .then((_) {
                    if (mounted) {
                      Navigator.pop(context); // Close modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.item.symbol} removed from portfolio',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  })
                  .onError((error, stackTrace) {
                    setState(() => _isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${error.toString()}')),
                      );
                    }
                  });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with coin info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Coin icon
                    if (widget.item.imageUrl != null)
                      Image.network(
                        widget.item.imageUrl!,
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.currency_bitcoin, size: 40),
                      )
                    else
                      const Icon(Icons.currency_bitcoin, size: 40),
                    const SizedBox(width: 12),
                    // Coin name and symbol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.item.name != null)
                            Text(
                              widget.item.name!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          Text(
                            widget.item.symbol,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Current value
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.item.totalValue.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${widget.item.currentPrice.toStringAsFixed(2)}/coin',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount input field
              TextFormField(
                controller: _amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount of ${widget.item.symbol}',
                  prefixIcon: const Icon(Icons.calculate),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Real-time total value preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total value:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _amountController,
                      builder: (context, value, child) {
                        final amount = double.tryParse(value.text) ?? 0;
                        final totalValue = amount * widget.item.currentPrice;
                        return Text(
                          '\$${totalValue.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade500,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdateAmount,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Amount'),
                ),
              ),
              const SizedBox(height: 8),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleDeleteAsset,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Coin'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
