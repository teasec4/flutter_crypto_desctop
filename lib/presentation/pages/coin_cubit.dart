import 'dart:async';
import 'dart:developer' as developer;
import 'package:crypto_desctop/core/cubits/connectivity_cubit.dart';
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

/// State emitted when coins are updated from network (silent background refresh)
class CoinUpdated extends CoinState {
  final List<Coin> coins;

  CoinUpdated(this.coins);
}

/// Cubit for managing the cryptocurrency coins list with pagination
/// Only loads coins when user is authenticated for security
class CoinCubit extends Cubit<CoinState> {
  final CoinRepo coinRepo;
  final ConnectivityCubit connectivityCubit;
  // API max per page is 100
  static const int coinsPerPage = 100;
  static const Duration autoRefreshInterval = Duration(minutes: 5);

  Timer? _autoRefreshTimer;
  bool _isAuthorized = false;
  StreamSubscription? _connectivitySubscription;

  CoinCubit(this.coinRepo, this.connectivityCubit) : super(CoinInitial()) {
    _listenToConnectivity();
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }

  /// Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = connectivityCubit.stream.listen((state) {
      developer.log('CoinCubit: Connectivity state changed - ${state is ConnectivityOnline ? 'ONLINE' : 'OFFLINE'}');
      
      // When going online, try to refresh if we have authorized user
      if (state is ConnectivityOnline && _isAuthorized) {
        developer.log('CoinCubit: Back online, attempting refresh');
        _loadCoinsNetwork(showLoading: false, forceFresh: true);
      }
      
      // When going offline, don't need to do anything - just keep cached data
      if (state is ConnectivityOffline) {
        developer.log('CoinCubit: Gone offline, will use cached data');
      }
    });
  }

  /// Starts auto-refresh timer - updates coins every 5 minutes in background
  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (_) {
      developer.log('CoinCubit: Auto-refresh timer triggered');
      _loadCoinsNetwork(showLoading: false);
    });
  }

  /// Set authorization status
  /// Security: Only load coins data when user is authorized
  void setAuthorized(bool authorized) {
    _isAuthorized = authorized;
    developer.log('CoinCubit: Authorization status set to $authorized');

    if (!authorized) {
      // Clear coins and stop background refresh when user logs out
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      emit(CoinInitial());
      developer.log('CoinCubit: Cleared coins on logout');
    } else {
      // Start loading coins when user logs in
      loadCoins();
    }
  }

  /// Initial load - tries cache first, then network in background
  /// Called when page is opened
  Future<void> loadCoins() async {
    // Security: Only load coins if user is authorized
    if (!_isAuthorized) {
      developer.log('CoinCubit: loadCoins skipped - user not authorized');
      emit(CoinInitial());
      return;
    }

    developer.log('CoinCubit: loadCoins called (initial or manual refresh)');

    // Start auto-refresh timer when data is loaded
    _startAutoRefreshTimer();

    // Try to load from cache first
    await _loadCoinsCached();

    // Then load from network fresh (with loading indicator)
    // Use forceFresh=true to get actual fresh data from server, not cache again
    await _loadCoinsNetwork(showLoading: true, forceFresh: true);
  }

  /// Loads coins from cache (non-blocking, shows immediately)
  Future<void> _loadCoinsCached() async {
    try {
      final cachedCoins = await coinRepo.getCoins(
        page: 1,
        perPage: coinsPerPage,
      );
      if (cachedCoins.isNotEmpty) {
        developer.log(
          'CoinCubit: Loaded ${cachedCoins.length} coins from cache',
        );
        emit(
          CoinLoaded(
            coins: cachedCoins,
            currentPage: 1,
            hasMorePages: cachedCoins.length == coinsPerPage,
          ),
        );
      }
    } catch (e) {
      developer.log(
        'CoinCubit: Cache load failed (expected on first run) - $e',
      );
    }
  }

  /// Loads coins from network with loading state
  /// [showLoading] - if true, emits CoinLoading state; if false, silently updates in background
  /// [forceFresh] - if true, bypasses cache and fetches from network directly
  Future<void> _loadCoinsNetwork({
    bool showLoading = true,
    bool forceFresh = false,
  }) async {
    try {
      final previousCoins = (state is CoinLoaded)
          ? (state as CoinLoaded).coins
          : <Coin>[];

      // Only show loading if explicitly requested
      if (showLoading) {
        emit(CoinLoading(previousCoins));
      }

      // Use fresh fetch if explicitly requested (manual refresh)
      final coinsList = forceFresh
          ? await coinRepo.getCoinsFresh(page: 1, perPage: coinsPerPage)
          : await coinRepo.getCoins(page: 1, perPage: coinsPerPage);

      developer.log('CoinCubit: Loaded ${coinsList.length} coins from network');
      if (coinsList.isNotEmpty) {
        developer.log(
          'CoinCubit: First coin - ${coinsList.first.name} (${coinsList.first.price})',
        );
      }

      final newState = CoinLoaded(
        coins: coinsList,
        currentPage: 1,
        hasMorePages: coinsList.length == coinsPerPage,
      );

      emit(newState);

      // Emit CoinUpdated for manual refreshes to show toast
      if (showLoading) {
        emit(CoinUpdated(coinsList));
        emit(newState); // Return to normal state after notification
      }
    } catch (e) {
      developer.log('CoinCubit: Network load failed - $e');
      final previousCoins = (state is CoinLoading)
          ? (state as CoinLoading).coins
          : <Coin>[];
      if (previousCoins.isEmpty && state is! CoinLoaded) {
        // If no previous data and initial load failed
        emit(CoinError(e.toString(), previousCoins: previousCoins));
      } else {
        // If we have cached data, keep showing it (silent error)
        developer.log('CoinCubit: Network failed but keeping cached data');
      }
    }
  }

  /// Manual refresh - force fresh network update with loading indicator
  Future<void> refreshCoins() async {
    developer.log('CoinCubit: refreshCoins called (manual pull-to-refresh)');
    await _loadCoinsNetwork(showLoading: true, forceFresh: true);
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
      emit(
        CoinLoaded(
          coins: allCoins,
          currentPage: nextPage,
          hasMorePages: newCoins.length == coinsPerPage,
        ),
      );
    } catch (e) {
      emit(CoinError(e.toString(), previousCoins: currentState.coins));
    }
  }
}
