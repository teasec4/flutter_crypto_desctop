import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/domain/repository/portfolio_repo.dart';
import 'package:flutter/foundation.dart';

part 'portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final CoinRepo coinRepo;
  String? _currentUserEmail;

  PortfolioCubit({required this.portfolioRepository, required this.coinRepo})
      : super(PortfolioInitial());

  /// Initialize user email (without loading portfolio)
  void initializeUser(String userEmail) {
    _currentUserEmail = userEmail;
  }

  /// Set current user email and load portfolio
  Future<void> loadPortfolio(String userEmail) async {
    _currentUserEmail = userEmail;
    emit(PortfolioLoading());

    try {
      final items = await portfolioRepository.getPortfolioItems(userEmail);
      
      // Fetch current prices for all portfolio items
      final enrichedItems = await _enrichItemsWithPrices(items);
      
      emit(PortfolioLoaded(enrichedItems));
    } catch (e) {
      emit(PortfolioError('Failed to load portfolio: ${e.toString()}'));
    }
  }

  /// Fetch current prices and info for portfolio items
  Future<List<PortfolioItem>> _enrichItemsWithPrices(
    List<PortfolioItem> items,
  ) async {
    try {
      // Load all coins from repository
      final allCoins = await coinRepo.getCoins();
      
      // Create a map of symbol -> coin for fast lookup
      final coinMap = {for (var coin in allCoins) coin.symbol.toLowerCase(): coin};
      
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
      await loadPortfolio(_currentUserEmail!);
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
      await loadPortfolio(_currentUserEmail!);
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
      await loadPortfolio(_currentUserEmail!);
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
