import 'package:crypto_desctop/domain/models/coin.dart';

/// Advanced search service with fuzzy matching and scoring algorithm
class CoinSearchService {
  /// Performs fuzzy search on coins with intelligent scoring
  /// Returns coins sorted by relevance score (highest first)
  static List<Coin> search(List<Coin> coins, String query) {
    if (query.isEmpty) return coins;

    final normalizedQuery = query.toLowerCase().trim();
    final results = <Coin, double>{};

    for (final coin in coins) {
      final score = _calculateScore(coin, normalizedQuery);
      if (score > 0) {
        results[coin] = score;
      }
    }

    // Sort by score descending
    final sorted = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).toList();
  }

  /// Calculates relevance score for a coin based on query
  /// Score logic (highest to lowest):
  /// 1. Exact name match: 1000
  /// 2. Name starts with: 800
  /// 3. Name contains: 600
  /// 4. Exact symbol match: 500
  /// 5. Symbol starts with: 400
  /// 6. Symbol contains: 200
  /// 7. Fuzzy match: 100 + edit distance bonus
  static double _calculateScore(Coin coin, String query) {
    final nameLower = coin.name.toLowerCase();
    final symbolLower = coin.symbol.toLowerCase();

    // Exact name match
    if (nameLower == query) return 1000;

    // Name starts with query
    if (nameLower.startsWith(query)) return 800;

    // Name contains query
    if (nameLower.contains(query)) return 600;

    // Exact symbol match
    if (symbolLower == query) return 500;

    // Symbol starts with query
    if (symbolLower.startsWith(query)) return 400;

    // Symbol contains query
    if (symbolLower.contains(query)) return 200;

    // Fuzzy match with Levenshtein distance
    final fuzzyScore = _calculateFuzzyScore(nameLower, query);
    if (fuzzyScore > 0) {
      return fuzzyScore;
    }

    final symbolFuzzyScore = _calculateFuzzyScore(symbolLower, query);
    if (symbolFuzzyScore > 0) {
      return symbolFuzzyScore * 0.5; // Symbol fuzzy match weighted less
    }

    return 0;
  }

  /// Calculates fuzzy match score using character sequence matching
  /// Returns score between 0 and 100 based on how well characters match in sequence
  static double _calculateFuzzyScore(String text, String query) {
    if (query.isEmpty) return 0;
    if (text.isEmpty) return 0;

    var textIndex = 0;
    var queryIndex = 0;
    var score = 0;
    var consecutiveMatches = 0;

    while (textIndex < text.length && queryIndex < query.length) {
      if (text[textIndex] == query[queryIndex]) {
        score += (10 + consecutiveMatches * 5);
        consecutiveMatches++;
        queryIndex++;
      } else {
        consecutiveMatches = 0;
      }
      textIndex++;
    }

    // Only return score if we matched all query characters
    if (queryIndex == query.length) {
      return (score.toDouble() / query.length).clamp(0, 100);
    }

    return 0;
  }

  /// Case-insensitive exact match on name or symbol
  static bool isExactMatch(Coin coin, String query) {
    final lowerQuery = query.toLowerCase();
    return coin.name.toLowerCase() == lowerQuery ||
        coin.symbol.toLowerCase() == lowerQuery;
  }

  /// Returns true if coin contains query text (case-insensitive)
  static bool containsQuery(Coin coin, String query) {
    final lowerQuery = query.toLowerCase();
    return coin.name.toLowerCase().contains(lowerQuery) ||
        coin.symbol.toLowerCase().contains(lowerQuery);
  }
}
