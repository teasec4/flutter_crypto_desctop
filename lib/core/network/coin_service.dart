import 'dart:convert';

import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:http/http.dart' as http;

class CoinService implements CoinRepo {
  @override
  Future<List<Coin>> getCoins() async {
    final perPage = 20;
    final page = 1;

    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets'
          '?vs_currency=usd&order=market_cap_desc'
          '&per_page=$perPage&page=$page&sparkline=false',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'crypto_desctop/1.0.0',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch coins: ${response.statusCode} ${response.body}');
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Coin.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Error fetching coins: $e");
    }
  }

  @override
  Future<Coin> getCoin(String id) {
    // TODO: implement getCoin
    throw UnimplementedError();
  }
}