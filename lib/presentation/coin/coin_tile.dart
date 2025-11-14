import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/router/app_router.dart';
import 'package:flutter/material.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;

  const CoinTile({super.key, required this.coin});

  String _getRankString(int rank) {
    if (rank == 0) return '';
    return '$rank';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getRankString(coin.marketCapRank),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Image.network(
            coin.imageUrl,
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 20),
          ),
        ],
      ),

      title: Text(
        coin.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),

      subtitle: Text(
        coin.symbol.toUpperCase(),
        style: const TextStyle(color: Colors.grey),
      ),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${coin.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${coin.priceChangePercentage24H.toStringAsFixed(2)}%',
            style: TextStyle(
              color: coin.priceChangePercentage24H >= 0
                  ? Colors.green
                  : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () => context.goToCoinDetail(coin.id),
    );
  }
}
