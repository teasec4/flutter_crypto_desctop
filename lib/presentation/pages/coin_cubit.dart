import 'dart:async';
import 'dart:developer' as developer;
import 'package:crypto_desctop/domain/models/coin.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for coin list view states
sealed class CoinState {}

/// Initial state before coins are loaded
class CoinInitial extends CoinState {}

/// Loading state while fetching coins from the API
class CoinLoading extends CoinState {
  final List<Coin> coins;
  CoinLoading(this.coins);
}

/// State when coins have been successfully loaded
class CoinLoaded extends CoinState {
  final List<Coin> coins;
  final int currentPage;
  final bool hasMorePages;
  
  CoinLoaded({
    required this.coins,
    required this.currentPage,
    this.hasMorePages = true,
  });
}

/// State indicating an error occurred while loading coins
class CoinError extends CoinState {
  final String message;
  final List<Coin> previousCoins;
  
  CoinError(this.message, {this.previousCoins = const []});
}

/// Cubit for managing the cryptocurrency coins list with pagination
class CoinCubit extends Cubit<CoinState> {
  final CoinRepo coinRepo;
  static const int coinsPerPage = 100;
  static const Duration autoRefreshInterval = Duration(minutes: 5);
  
  Timer? _autoRefreshTimer;

  CoinCubit(this.coinRepo) : super(CoinInitial());

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }

  /// Starts auto-refresh timer - updates coins every 5 minutes in background
  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (_) {
      developer.log('CoinCubit: Auto-refresh timer triggered');
      _loadCoinsNetwork(showLoading: false);
    });
  }

  /// Initial load - tries cache first, then network in background
  /// Called when page is opened
  Future<void> loadCoins() async {
    developer.log('CoinCubit: loadCoins called (initial or manual refresh)');
    
    // Start auto-refresh timer when data is loaded
    _startAutoRefreshTimer();
    
    // Try to load from cache first
    await _loadCoinsCached();
    
    // Then load from network (with loading indicator)
    await _loadCoinsNetwork(showLoading: true);
  }

  /// Loads coins from cache (non-blocking, shows immediately)
  Future<void> _loadCoinsCached() async {
    try {
      final cachedCoins = await coinRepo.getCoins(page: 1, perPage: coinsPerPage);
      if (cachedCoins.isNotEmpty) {
        developer.log('CoinCubit: Loaded ${cachedCoins.length} coins from cache');
        emit(CoinLoaded(
          coins: cachedCoins,
          currentPage: 1,
          hasMorePages: cachedCoins.length == coinsPerPage,
        ));
      }
    } catch (e) {
      developer.log('CoinCubit: Cache load failed (expected on first run) - $e');
    }
  }

  /// Loads coins from network with loading state
  /// [showLoading] - if true, emits CoinLoading state; if false, silently updates in background
  Future<void> _loadCoinsNetwork({bool showLoading = true}) async {
    try {
      final previousCoins = (state is CoinLoaded) ? (state as CoinLoaded).coins : <Coin>[];
      
      // Only show loading if explicitly requested
      if (showLoading) {
        emit(CoinLoading(previousCoins));
      }
      
      final coinsList = await coinRepo.getCoins(page: 1, perPage: coinsPerPage);
      
      developer.log('CoinCubit: Loaded ${coinsList.length} coins from network');
      if (coinsList.isNotEmpty) {
        developer.log('CoinCubit: First coin - ${coinsList.first.name} (${coinsList.first.price})');
      }
      
      emit(CoinLoaded(
        coins: coinsList,
        currentPage: 1,
        hasMorePages: coinsList.length == coinsPerPage,
      ));
    } catch (e) {
      developer.log('CoinCubit: Network load failed - $e');
      final previousCoins = (state is CoinLoading) ? (state as CoinLoading).coins : <Coin>[];
      if (previousCoins.isEmpty && state is! CoinLoaded) {
        // If no previous data and initial load failed
        emit(CoinError(e.toString(), previousCoins: previousCoins));
      } else {
        // If we have cached data, keep showing it (silent error)
        developer.log('CoinCubit: Network failed but keeping cached data');
      }
    }
  }

  /// Manual refresh - force network update with loading indicator
  Future<void> refreshCoins() async {
    developer.log('CoinCubit: refreshCoins called (manual pull-to-refresh)');
    await _loadCoinsNetwork(showLoading: true);
  }

  /// Loads the next page of coins and appends to existing list
  Future<void> loadMoreCoins() async {
    final currentState = state;
    if (currentState is! CoinLoaded) return;
    if (!currentState.hasMorePages) return;

    try {
      final nextPage = currentState.currentPage + 1;
      emit(CoinLoading(currentState.coins));
      
      final newCoins = await coinRepo.getCoins(
        page: nextPage,
        perPage: coinsPerPage,
      );

      final allCoins = [...currentState.coins, ...newCoins];
      emit(CoinLoaded(
        coins: allCoins,
        currentPage: nextPage,
        hasMorePages: newCoins.length == coinsPerPage,
      ));
    } catch (e) {
      emit(CoinError(e.toString(), previousCoins: currentState.coins));
    }
  }
}
