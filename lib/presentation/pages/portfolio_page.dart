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
    return BlocListener<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        // Show toast when portfolio is updated in background
        if (state is PortfolioUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Portfolio updated'),
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
      child: BlocBuilder<PortfolioCubit, PortfolioState>(
        builder: (context, state) {
          // Get items and loading state
          List<PortfolioItem> items = [];
          bool isLoading = false;

          if (state is PortfolioLoading) {
            items = state.items;
            isLoading = true;
          } else if (state is PortfolioLoaded) {
            items = state.items;
            isLoading = false;
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

          // Show empty portfolio if no items
          if (items.isEmpty) {
            return _buildEmptyPortfolio(context);
          }

          // Calculate total portfolio value
          double totalValue = 0;
          for (var item in items) {
            if (item.totalValue.isNaN || item.totalValue.isInfinite) {
              continue;
            }
            totalValue += item.totalValue;
          }

          // Validate total value
          if (totalValue.isNaN || totalValue.isInfinite) {
            totalValue = 0;
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () =>
                    context.read<PortfolioCubit>().refreshPortfolio(),
                child: Column(
                  children: [
                    // Total portfolio value - Apple style card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width > 350
                            ? 350
                            : double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Portfolio Balance',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${totalValue.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${items.length} assets',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Portfolio items list - Apple style minimal
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          if (index >= items.length) {
                            return const SizedBox();
                          }
                          final item = items[index];
                          if (_isValidPortfolioItem(item)) {
                            return _buildPortfolioTile(
                              context,
                              item,
                              totalValue,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Loading overlay
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a tile widget for a single portfolio item - Apple style minimal
  Widget _buildPortfolioTile(
    BuildContext context,
    PortfolioItem item,
    double totalValue,
  ) {
    final percentage = totalValue > 0
        ? (item.totalValue / totalValue * 100)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditPortfolioModal(context, item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Cryptocurrency icon - smaller
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                  ),
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.currency_bitcoin, size: 20),
                        )
                      : const Icon(Icons.currency_bitcoin, size: 20),
                ),
                const SizedBox(width: 12),
                // Coin symbol and amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.symbol,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.amount.toStringAsFixed(4)} ${item.symbol}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: UIUtils.getSecondaryTextColor(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Total value and percentage - right side
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.totalValue.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                  backgroundColor: Colors.green.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          })
          .onError((error, stackTrace) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error.toString()}'),
                  backgroundColor: Colors.red.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                          backgroundColor: Colors.green.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  })
                  .onError((error, stackTrace) {
                    setState(() => _isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${error.toString()}'),
                          backgroundColor: Colors.red.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
