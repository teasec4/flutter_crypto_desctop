part of 'portfolio_cubit.dart';

@immutable
sealed class PortfolioState {}

final class PortfolioInitial extends PortfolioState {}

final class PortfolioLoading extends PortfolioState {}

final class PortfolioLoaded extends PortfolioState {
  final List<PortfolioItem> items;

  PortfolioLoaded(this.items);
}

final class PortfolioError extends PortfolioState {
  final String message;

  PortfolioError(this.message);
}

final class PortfolioItemAdded extends PortfolioState {
  final PortfolioItem item;

  PortfolioItemAdded(this.item);
}

final class PortfolioItemUpdated extends PortfolioState {
  final PortfolioItem item;

  PortfolioItemUpdated(this.item);
}

final class PortfolioItemRemoved extends PortfolioState {
  final String itemId;

  PortfolioItemRemoved(this.itemId);
}
