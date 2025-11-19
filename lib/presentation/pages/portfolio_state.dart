part of 'portfolio_cubit.dart';

/// Base class for all portfolio states
@immutable
sealed class PortfolioState {}

/// Initial state before portfolio is loaded
final class PortfolioInitial extends PortfolioState {}

/// Loading state while fetching portfolio data
final class PortfolioLoading extends PortfolioState {
  final List<PortfolioItem> items;

  PortfolioLoading(this.items);
}

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

/// State emitted when portfolio is updated from network (silent background refresh)
final class PortfolioUpdated extends PortfolioState {
  final List<PortfolioItem> items;

  PortfolioUpdated(this.items);
}
