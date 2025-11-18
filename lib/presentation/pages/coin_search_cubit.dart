import 'dart:developer' as developer;
import 'package:crypto_desctop/core/search/coin_search_service.dart';
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for coin search states
sealed class CoinSearchState {}

/// Initial state - no search has been performed
class CoinSearchInitial extends CoinSearchState {}

/// Searching state - user is typing, search in progress
class CoinSearching extends CoinSearchState {
  final String query;
  final List<Coin> results;
  final bool isLoadingMore;

  CoinSearching({
    required this.query,
    required this.results,
    this.isLoadingMore = false,
  });
}

/// Search completed - results displayed
class CoinSearchResult extends CoinSearchState {
  final String query;
  final List<Coin> results;
  final int totalMatches;

  CoinSearchResult({
    required this.query,
    required this.results,
    required this.totalMatches,
  });
}

/// No results found for query
class CoinSearchEmpty extends CoinSearchState {
  final String query;

  CoinSearchEmpty(this.query);
}

/// Cubit for managing coin search with fuzzy matching
/// Auto-loads additional coin pages when search yields no results
class CoinSearchCubit extends Cubit<CoinSearchState> {
  final List<Coin> allCoins;
  final CoinRepo coinRepo;
  String _currentQuery = '';
  int _nextPageToLoad = 2; // Start with page 2 (page 1 is already loaded)
  static const int coinsPerPage = 100; // Match CoinCubit's page size

  CoinSearchCubit({required this.allCoins, required this.coinRepo})
    : super(CoinSearchInitial());

  /// Performs search on coins with fuzzy matching
  /// If no results found, automatically loads next page of coins
  Future<void> search(String query) async {
    _currentQuery = query;
    developer.log('CoinSearchCubit: Search for "$query"');

    if (query.isEmpty) {
      emit(CoinSearchInitial());
      return;
    }

    // Perform search using the search service
    final results = CoinSearchService.search(allCoins, query);

    if (results.isEmpty) {
      developer.log(
        'CoinSearchCubit: No results for "$query", loading next page',
      );
      // Try to load more coins from next page
      await _loadAndSearchNextPage(query);
    } else {
      developer.log(
        'CoinSearchCubit: Found ${results.length} results for "$query"',
      );
      emit(
        CoinSearchResult(
          query: query,
          results: results,
          totalMatches: results.length,
        ),
      );
      // Reset page counter for next search
      _nextPageToLoad = 2;
    }
  }

  /// Loads next page of coins and searches again
  /// Continues loading pages until results found or max pages reached
  Future<void> _loadAndSearchNextPage(String query) async {
    const maxPagesToSearch = 10; // Limit to 1000 coins (10 pages * 100)

    while (_nextPageToLoad <= maxPagesToSearch) {
      try {
        // Emit loading state
        emit(
          CoinSearching(query: query, results: allCoins, isLoadingMore: true),
        );

        developer.log(
          'CoinSearchCubit: Loading page $_nextPageToLoad to search for "$query"',
        );

        // Load coins from next page
        final newCoins = await coinRepo.getCoins(
          page: _nextPageToLoad,
          perPage: coinsPerPage,
        );

        if (newCoins.isEmpty) {
          // No more coins available
          developer.log('CoinSearchCubit: No more coins available');
          emit(CoinSearchEmpty(query));
          _nextPageToLoad = 2; // Reset
          return;
        }

        // Add new coins to search pool
        allCoins.addAll(newCoins);
        developer.log(
          'CoinSearchCubit: Loaded ${newCoins.length} more coins, total: ${allCoins.length}',
        );

        // Search in updated coins list
        final results = CoinSearchService.search(allCoins, query);

        if (results.isNotEmpty) {
          // Found results!
          developer.log(
            'CoinSearchCubit: Found ${results.length} results for "$query" on page $_nextPageToLoad',
          );
          emit(
            CoinSearchResult(
              query: query,
              results: results,
              totalMatches: results.length,
            ),
          );
          _nextPageToLoad = 2; // Reset for next search
          return;
        }

        // No results on this page, try next page
        _nextPageToLoad++;
      } catch (e) {
        developer.log(
          'CoinSearchCubit: Error loading page $_nextPageToLoad - $e',
        );
        emit(CoinSearchEmpty(query));
        _nextPageToLoad = 2; // Reset on error
        return;
      }
    }

    // Reached max pages without finding results
    developer.log(
      'CoinSearchCubit: No results found across $maxPagesToSearch pages',
    );
    emit(CoinSearchEmpty(query));
    _nextPageToLoad = 2; // Reset
  }

  /// Clears search and returns to initial state
  void clearSearch() {
    _currentQuery = '';
    _nextPageToLoad = 2; // Reset page counter
    emit(CoinSearchInitial());
    developer.log('CoinSearchCubit: Search cleared');
  }

  /// Returns current search query
  String get currentQuery => _currentQuery;

  /// Updates the coins list (call when coins are refreshed from network)
  void updateCoins(List<Coin> newCoins) {
    developer.log(
      'CoinSearchCubit: Coins updated with ${newCoins.length} coins',
    );
    allCoins.clear();
    allCoins.addAll(newCoins);
    _nextPageToLoad = 2; // Reset page counter

    // If there's an active search, re-search with new coins
    if (_currentQuery.isNotEmpty) {
      search(_currentQuery);
    }
  }
}
