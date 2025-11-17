part of 'auth_cubit.dart';

/// Base class for all authentication states
@immutable
sealed class AuthState {}

/// Initial state before any authentication attempt
final class AuthInitial extends AuthState {}

/// Loading state during authentication process
final class AuthLoading extends AuthState {}

/// State when user is authenticated (carries user data)
final class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

/// State indicating authentication failure with error message
final class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

/// State when user is authenticated but data is still loading
/// Shows splash screen while portfolio and coins are being fetched
final class AuthInitializing extends AuthState {
  final User user;
  AuthInitializing(this.user);
}
