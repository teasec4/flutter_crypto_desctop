import 'package:crypto_desctop/di/service_locator.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/presentation/pages/coin_detail_cubit.dart';
import 'package:crypto_desctop/presentation/widgets/coin_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailPage extends StatefulWidget {
  final String coinId;

  const CoinDetailPage({super.key, required this.coinId});

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  late int _selectedChartDays;

  @override
  void initState() {
    super.initState();
    _selectedChartDays = 30;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoinDetailCubit(getIt<CoinRepo>())
            ..loadCoin(widget.coinId, chartDays: _selectedChartDays),
      child: CoinDetailView(
        selectedChartDays: _selectedChartDays,
        onChartDaysChanged: (days) {
          setState(() {
            _selectedChartDays = days;
          });
          context.read<CoinDetailCubit>().loadCoin(
            widget.coinId,
            chartDays: days,
          );
        },
      ),
    );
  }
}

class CoinDetailView extends StatelessWidget {
  final Function(int)? onChartDaysChanged;
  final int selectedChartDays;

  const CoinDetailView({
    super.key,
    this.onChartDaysChanged,
    this.selectedChartDays = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<CoinDetailCubit, CoinDetailState>(
          builder: (context, state) {
            if (state is CoinDetailLoaded) {
              final coin = state.coin;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    coin.imageUrl,
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.currency_bitcoin,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    coin.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CoinDetailCubit, CoinDetailState>(
          builder: (context, state) {
            if (state is CoinDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CoinDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load coin details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<CoinDetailCubit>()
                            .loadCoin(state.coinId ?? '', chartDays: selectedChartDays),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is CoinDetailLoaded) {
              final coin = state.coin;
              final chartData = state.chartData;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Price chart - properly centered
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: chartData != null
                            ? CoinChartWidget(
                                chartData: chartData,
                                selectedDays: selectedChartDays,
                                onDaysChanged: (days) {
                                  onChartDaysChanged?.call(days);
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 24h Change stats - centered under graph
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '24h Change',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${coin.priceChangePercentage24H.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: coin.priceChangePercentage24H >= 0
                                    ? Colors.green.shade500
                                    : Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 48),
                        Column(
                          children: [
                            Text(
                              '24h Change (\$)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${coin.priceChange24H.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: coin.priceChange24H >= 0
                                    ? Colors.green.shade500
                                    : Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
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
