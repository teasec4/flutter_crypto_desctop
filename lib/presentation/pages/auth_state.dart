part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

final class AuthSuccess extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
