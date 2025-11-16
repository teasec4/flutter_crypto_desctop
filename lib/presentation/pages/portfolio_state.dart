part of 'portfolio_cubit.dart';

/// Base class for all portfolio states
@immutable
sealed class PortfolioState {}

/// Initial state before portfolio is loaded
final class PortfolioInitial extends PortfolioState {}

/// Loading state while fetching portfolio data
final class PortfolioLoading extends PortfolioState {}

/// State when portfolio items have been successfully loaded
final class PortfolioLoaded extends PortfolioState {
  final List<PortfolioItem> items;

  PortfolioLoaded(this.items);
}

/// State indicating an error occurred during portfolio operations
final class PortfolioError extends PortfolioState {
  final String message;

  PortfolioError(this.message);
}

/// State emitted after successfully adding an item to portfolio
final class PortfolioItemAdded extends PortfolioState {
  final PortfolioItem item;

  PortfolioItemAdded(this.item);
}

/// State emitted after successfully updating a portfolio item
final class PortfolioItemUpdated extends PortfolioState {
  final PortfolioItem item;

  PortfolioItemUpdated(this.item);
}

/// State emitted after successfully removing an item from portfolio
final class PortfolioItemRemoved extends PortfolioState {
  final String itemId;

  PortfolioItemRemoved(this.itemId);
}
