import 'package:crypto_desctop/core/network/coin_service.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/presentation/coin/coin_tile.dart';
import 'package:flutter/material.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  final CoinService _coinService = CoinService();
  late Future<List<Coin>> _coinsFuture;

  @override
  void initState() {
    super.initState();
    _coinsFuture = _coinService.getCoins();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.symmetric(vertical: 10, horizontal: 10) ,
      child: FutureBuilder<List<Coin>>(
        future: _coinsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No coins found'));
          } else {
            final coins = snapshot.data!;
            return ListView.builder(
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                return CoinTile(coin: coin);
              },
            );
          }
        },
      ),
    );
  }
}
