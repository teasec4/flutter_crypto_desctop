import 'dart:async';
import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/domain/repository/portfolio_repo.dart';
import 'package:flutter/foundation.dart';

part 'portfolio_state.dart';

/// Cubit for managing user cryptocurrency portfolio
/// Handles portfolio operations: loading, adding, updating, and removing assets
/// Caches portfolio data to avoid unnecessary network requests
class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final CoinRepo coinRepo;
  String? _currentUserEmail;
  Timer? _autoRefreshTimer;
  static const Duration autoRefreshInterval = Duration(minutes: 5);

  PortfolioCubit({required this.portfolioRepository, required this.coinRepo})
    : super(PortfolioInitial());

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }

  /// Starts auto-refresh timer - updates portfolio every 5 minutes in background
  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (_) {
      developer.log('PortfolioCubit: Auto-refresh timer triggered');
      _loadPortfolioNetwork(showLoading: false);
    });
  }

  /// Initialize user email and load portfolio on app startup
  Future<void> initializeUser(String userEmail) async {
    _currentUserEmail = userEmail;
    await loadPortfolioInitial(userEmail);
  }

  /// Initial load - tries cache first, then network in background
  /// Called when user logs in or app starts
  Future<void> loadPortfolioInitial(String userEmail) async {
    developer.log('PortfolioCubit: loadPortfolioInitial called');
    _currentUserEmail = userEmail;

    // Start auto-refresh timer when data is loaded
    _startAutoRefreshTimer();

    // Try to load from cache first
    await _loadPortfolioFromCache(userEmail);

    // Then load from network (with loading indicator)
    await _loadPortfolioNetwork(showLoading: true, userEmail: userEmail);
  }

  /// Loads portfolio from cache (non-blocking, shows immediately)
  Future<void> _loadPortfolioFromCache(String userEmail) async {
    try {
      final items = await portfolioRepository.getPortfolioItems(userEmail);
      if (items.isNotEmpty) {
        developer.log(
          'PortfolioCubit: Loaded ${items.length} items from cache',
        );
        final enrichedItems = await _enrichItemsWithPrices(items);
        emit(PortfolioLoaded(enrichedItems));
      }
    } catch (e) {
      developer.log('PortfolioCubit: Cache load failed - $e');
    }
  }

  /// Loads portfolio from network with loading state
  /// [showLoading] - if true, emits PortfolioLoading state; if false, silently updates in background
  /// [forceFresh] - if true, bypasses cache and fetches from network directly
  Future<void> _loadPortfolioNetwork({
    bool showLoading = true,
    String? userEmail,
    bool forceFresh = false,
  }) async {
    final email = userEmail ?? _currentUserEmail;
    if (email == null) return;

    try {
      // Only show loading if explicitly requested
      if (showLoading) {
        emit(PortfolioLoading());
      }

      // Use fresh fetch if explicitly requested (manual refresh)
      final items = forceFresh
          ? await portfolioRepository.getPortfolioItemsFresh(email)
          : await portfolioRepository.getPortfolioItems(email);

      // Fetch current prices for all portfolio items
      final enrichedItems = await _enrichItemsWithPrices(items);

      developer.log(
        'PortfolioCubit: Loaded ${enrichedItems.length} items from network',
      );
      emit(PortfolioLoaded(enrichedItems));
    } catch (e) {
      developer.log('PortfolioCubit: Network load failed - $e');
      final previousItems = (state is PortfolioLoaded)
          ? (state as PortfolioLoaded).items
          : <PortfolioItem>[];

      if (previousItems.isEmpty && state is! PortfolioLoaded) {
        // If no previous data and initial load failed
        emit(PortfolioError('Failed to load portfolio: ${e.toString()}'));
      } else {
        // If we have cached data, keep showing it (silent error)
        developer.log('PortfolioCubit: Network failed but keeping cached data');
      }
    }
  }

  /// Manual refresh - force fresh network update with loading indicator
  Future<void> refreshPortfolio() async {
    developer.log('PortfolioCubit: refreshPortfolio called (manual)');
    await _loadPortfolioNetwork(showLoading: true, forceFresh: true);
  }

  /// Fetch current prices and info for portfolio items
  Future<List<PortfolioItem>> _enrichItemsWithPrices(
    List<PortfolioItem> items,
  ) async {
    try {
      // Load all coins from repository
      final allCoins = await coinRepo.getCoins();

      // Create a map of symbol -> coin for fast lookup
      final coinMap = {
        for (var coin in allCoins) coin.symbol.toLowerCase(): coin,
      };

      // Enrich portfolio items with current prices
      return items.map((item) {
        final coin = coinMap[item.symbol.toLowerCase()];
        if (coin != null) {
          return item.copyWith(
            currentPrice: coin.price,
            imageUrl: coin.imageUrl,
            name: coin.name,
          );
        }
        return item;
      }).toList();
    } catch (e) {
      debugPrint('Error enriching portfolio items with prices: $e');
      // Return original items if price fetch fails
      return items;
    }
  }

  /// Add new asset to portfolio
  Future<void> addAsset(String symbol, double amount) async {
    if (_currentUserEmail == null) {
      emit(PortfolioError('User not authenticated'));
      return;
    }

    try {
      final item = PortfolioItem(
        id: symbol.toLowerCase(),
        symbol: symbol.toUpperCase(),
        amount: amount,
        addedAt: DateTime.now(),
      );

      await portfolioRepository.addPortfolioItem(_currentUserEmail!, item);
      emit(PortfolioItemAdded(item));

      // Reload portfolio after adding
      developer.log('PortfolioCubit: Asset added, reloading portfolio');
      await _loadPortfolioNetwork(showLoading: false);
    } catch (e) {
      emit(PortfolioError('Failed to add asset: ${e.toString()}'));
    }
  }

  /// Update amount of existing portfolio item
  Future<void> updateAssetAmount(String itemId, double newAmount) async {
    if (_currentUserEmail == null) {
      emit(PortfolioError('User not authenticated'));
      return;
    }

    try {
      await portfolioRepository.updatePortfolioItemAmount(
        _currentUserEmail!,
        itemId,
        newAmount,
      );

      // Reload portfolio after updating
      developer.log('PortfolioCubit: Asset updated, reloading portfolio');
      await _loadPortfolioNetwork(showLoading: false);
    } catch (e) {
      emit(PortfolioError('Failed to update asset: ${e.toString()}'));
    }
  }

  /// Remove asset from portfolio
  Future<void> removeAsset(String itemId) async {
    if (_currentUserEmail == null) {
      emit(PortfolioError('User not authenticated'));
      return;
    }

    try {
      await portfolioRepository.removePortfolioItem(_currentUserEmail!, itemId);
      emit(PortfolioItemRemoved(itemId));

      // Reload portfolio after removing
      developer.log('PortfolioCubit: Asset removed, reloading portfolio');
      await _loadPortfolioNetwork(showLoading: false);
    } catch (e) {
      emit(PortfolioError('Failed to remove asset: ${e.toString()}'));
    }
  }

  /// Clear local state when user logs out
  /// Portfolio data on server is NOT deleted
  void clear() {
    _currentUserEmail = null;
    emit(PortfolioInitial());
  }

  /// Delete entire portfolio from server (called when user explicitly wants to clear it)
  Future<void> clearPortfolio() async {
    if (_currentUserEmail == null) {
      emit(PortfolioInitial());
      return;
    }

    try {
      await portfolioRepository.clearUserPortfolio(_currentUserEmail!);
      _currentUserEmail = null;
      emit(PortfolioInitial());
    } catch (e) {
      emit(PortfolioError('Failed to clear portfolio: ${e.toString()}'));
    }
  }
}
