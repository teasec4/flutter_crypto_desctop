import 'package:crypto_desctop/core/utils/ui_utils.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/presentation/pages/auth_cubit.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:crypto_desctop/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A list tile widget that displays a cryptocurrency coin with its price and market info
class CoinTile extends StatelessWidget {
  final Coin coin;

  const CoinTile({super.key, required this.coin});

  /// Shows a modal bottom sheet for adding this coin to the user's portfolio
  void _showAddToPortfolioModal(BuildContext context) {
    final portfolioCubit = context.read<PortfolioCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddToPortfolioSheet(
        coin: coin,
        portfolioCubit: portfolioCubit,
        authCubit: authCubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          minVerticalPadding: 0,
          dense: true,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Market cap rank
              Text(
                UIUtils.formatRank(coin.marketCapRank),
                style: TextStyle(
                  fontSize: 11,
                  color: UIUtils.getSecondaryTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Coin icon/image
              Image.network(
                coin.imageUrl,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 20),
              ),
            ],
          ),
          // Coin name
          title: Text(
            coin.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          // Coin symbol
          subtitle: Text(
            coin.symbol.toUpperCase(),
            style: TextStyle(
              color: UIUtils.getSecondaryTextColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price and 24h change
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Current price
                  Text(
                    '\$${coin.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  // 24 hour price change percentage
                  Text(
                    '${coin.priceChangePercentage24H.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: coin.priceChangePercentage24H >= 0
                          ? Colors.green.shade500
                          : Colors.red.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Add to portfolio button
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add_sharp),
                  onPressed: () => _showAddToPortfolioModal(context),
                ),
              ),
            ],
          ),
          // Navigate to coin detail page on tap
          onTap: () => context.goToCoinDetail(coin.id),
        ),
        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: UIUtils.getSecondaryTextColor(context).withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

/// Modal bottom sheet for adding a coin to the portfolio
class _AddToPortfolioSheet extends StatefulWidget {
  final Coin coin;
  final PortfolioCubit portfolioCubit;
  final AuthCubit authCubit;

  const _AddToPortfolioSheet({
    required this.coin,
    required this.portfolioCubit,
    required this.authCubit,
  });

  @override
  State<_AddToPortfolioSheet> createState() => _AddToPortfolioSheetState();
}

class _AddToPortfolioSheetState extends State<_AddToPortfolioSheet> {
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Handles the addition of the coin to the user's portfolio
  void _handleAddToPortfolio() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);

      setState(() => _isLoading = true);

      try {
        // Get current user email from auth cubit
        final userEmail = widget.authCubit.getCurrentUserEmail();

        if (userEmail == null) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not authenticated')),
            );
          }
          return;
        }

        // Initialize portfolio cubit with user email
        widget.portfolioCubit.initializeUser(userEmail);

        widget.portfolioCubit
            .addAsset(widget.coin.symbol, amount)
            .then((_) {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.coin.symbol.toUpperCase()} added to portfolio',
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
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
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
              // Header with coin info and price details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Coin icon
                    Image.network(
                      widget.coin.imageUrl,
                      width: 40,
                      height: 40,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.error, size: 40),
                    ),
                    const SizedBox(width: 12),
                    // Coin name and symbol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.coin.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.coin.symbol.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Current price and change
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.coin.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.coin.priceChangePercentage24H.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: widget.coin.priceChangePercentage24H >= 0
                                ? Colors.green.shade500
                                : Colors.red.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText:
                      'Enter amount of ${widget.coin.symbol.toUpperCase()}',
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
                        final totalValue = amount * widget.coin.price;
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

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAddToPortfolio,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Add ${widget.coin.symbol.toUpperCase()} to Portfolio',
                        ),
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
