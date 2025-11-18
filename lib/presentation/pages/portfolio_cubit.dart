import 'dart:async';
import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/domain/repository/portfolio_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'portfolio_state.dart';

/// Cubit for managing user cryptocurrency portfolio
/// Handles portfolio operations: loading, adding, updating, and removing assets
/// Caches portfolio data to avoid unnecessary network requests
class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final CoinRepo coinRepo;
  String _currentUserEmail = ''; // Initialize as empty string, never null
  Timer? _autoRefreshTimer;
  bool _isLoadingPortfolio = false; // Prevent concurrent portfolio loads
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

    // Don't start auto-refresh yet - it will start after first load completes
    // Try to load from cache first (quick display)
    await _loadPortfolioFromCache(userEmail);

    // Then load from network fresh (with loading indicator)
    // Use forceFresh=true to get actual fresh data from server
    // This will also start auto-refresh timer when completed
    await _loadPortfolioNetwork(
      showLoading: true,
      userEmail: userEmail,
      forceFresh: true,
    );
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
    if (email.isEmpty) {
      developer.log(
        'PortfolioCubit: User email not set, skipping network load',
      );
      return;
    }

    // Prevent concurrent loads to avoid race conditions and duplicate items
    if (_isLoadingPortfolio) {
      developer.log('PortfolioCubit: Load already in progress, skipping');
      return;
    }

    _isLoadingPortfolio = true;
    // Cancel auto-refresh during manual load to prevent background sync interference
    _autoRefreshTimer?.cancel();

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
    } finally {
      _isLoadingPortfolio = false;
      // Restart auto-refresh timer after load completes
      _startAutoRefreshTimer();
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
    developer.log(
      'PortfolioCubit: addAsset called with symbol=$symbol, amount=$amount, currentUserEmail=$_currentUserEmail',
    );

    if (_currentUserEmail.isEmpty) {
      developer.log('PortfolioCubit: ERROR - User email is empty!');
      emit(PortfolioError('User not authenticated'));
      return;
    }

    try {
      // Generate UUID for the item
      final uuid = const Uuid().v4();

      final item = PortfolioItem(
        id: uuid, // Use UUID instead of symbol
        symbol: symbol.toUpperCase(),
        amount: amount,
        addedAt: DateTime.now(),
      );

      developer.log(
        'PortfolioCubit: Adding item to repository: id=${item.id}, symbol=${item.symbol}, amount=${item.amount}',
      );
      await portfolioRepository.addPortfolioItem(_currentUserEmail, item);

      developer.log(
        'PortfolioCubit: Item added successfully, reloading portfolio',
      );
      // Reload portfolio after adding with fresh data from server
      // Use forceFresh=true to ensure we get latest data from server
      await _loadPortfolioNetwork(showLoading: true, forceFresh: true);
      developer.log('PortfolioCubit: Portfolio reloaded after add');
    } catch (e) {
      developer.log('PortfolioCubit: ERROR in addAsset - $e');
      emit(PortfolioError('Failed to add asset: ${e.toString()}'));
    }
  }

  /// Update amount of existing portfolio item
  /// Returns the updated portfolio items after reload
  Future<void> updateAssetAmount(String itemId, double newAmount) async {
    if (_currentUserEmail.isEmpty) {
      emit(PortfolioError('User not authenticated'));
      return;
    }

    try {
      await portfolioRepository.updatePortfolioItemAmount(
        _currentUserEmail,
        itemId,
        newAmount,
      );

      // Reload portfolio after updating with fresh data from server
      developer.log('PortfolioCubit: Asset updated, reloading portfolio');
      // Use forceFresh=true to ensure we get latest data from server
      await _loadPortfolioNetwork(showLoading: true, forceFresh: true);
    } catch (e) {
      emit(PortfolioError('Failed to update asset: ${e.toString()}'));
    }
  }

  /// Remove asset from portfolio
  Future<void> removeAsset(String itemId) async {
    if (_currentUserEmail.isEmpty) {
      emit(PortfolioError('User not authenticated'));
      return;
    }

    try {
      await portfolioRepository.removePortfolioItem(_currentUserEmail, itemId);

      // Reload portfolio after removing with fresh data from server
      developer.log('PortfolioCubit: Asset removed, reloading portfolio');
      // Use forceFresh=true to ensure we get latest data from server
      await _loadPortfolioNetwork(showLoading: true, forceFresh: true);
    } catch (e) {
      emit(PortfolioError('Failed to remove asset: ${e.toString()}'));
    }
  }

  /// Clear local state when user logs out
  /// Portfolio data on server is NOT deleted
  void clear() {
    _currentUserEmail = '';
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    emit(PortfolioInitial());
    developer.log('PortfolioCubit: Cleared');
  }
  
}
