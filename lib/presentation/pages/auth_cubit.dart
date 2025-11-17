import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:crypto_desctop/domain/repository/auth_repo.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  PortfolioCubit? portfolioCubit;
  User? currentUser;

  AuthCubit(this.authRepository) : super(AuthInitial());

  /// Set portfolio cubit reference for loading portfolio on auth
  void setPortfolioCubit(PortfolioCubit cubit) {
    portfolioCubit = cubit;
  }

  /// Register new user
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    emit(AuthLoading());
    try {
      currentUser = await authRepository.register(email, password, displayName);
      // Verify user is logged in after registration
      final isLoggedIn = await authRepository.isUserLoggedIn();
      if (isLoggedIn && currentUser != null) {
        emit(AuthAuthenticated(currentUser!));
        // Load portfolio for new user
        portfolioCubit?.initializeUser(email);
      } else {
        emit(AuthFailure('Registration succeeded but user is not logged in'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  /// Login existing user
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      currentUser = await authRepository.login(email, password);
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser!));
        // Load portfolio for logged in user
        portfolioCubit?.initializeUser(email);
      } else {
        emit(AuthFailure('Login failed: user data not available'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  /// Logout current user
  /// Note: Portfolio is NOT deleted - it stays on server for next login
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      currentUser = null;

      // Clear portfolio and stop background syncs
      portfolioCubit?.clear();

      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Logout failed: ${e.toString()}'));
    }
  }

  /// Check if user is logged in
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await authRepository.isUserLoggedIn();
      if (isLoggedIn) {
        currentUser = await authRepository.getCurrentUser();
        if (currentUser != null) {
          emit(AuthAuthenticated(currentUser!));
          // Load portfolio on app startup if user is already logged in
          portfolioCubit?.initializeUser(currentUser!.email);
        } else {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure('Auth check failed: ${e.toString()}'));
    }
  }

  /// Get current user email
  String? getCurrentUserEmail() => currentUser?.email;
}
