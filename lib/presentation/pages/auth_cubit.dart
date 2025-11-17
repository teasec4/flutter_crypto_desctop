import 'package:bloc/bloc.dart';
import 'package:crypto_desctop/domain/models/user_model.dart';
import 'package:crypto_desctop/domain/repository/auth_repo.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

/// Manages user authentication and initializes user data (portfolio + coins)
///
/// Auth Flow:
/// 1. login() → AuthLoading
/// 2. _initializeUserData() loads portfolio & coins in parallel
/// 3. → AuthAuthenticated (router redirects to home)
///
/// logout() → AuthInitial (clears portfolio & coins)
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  PortfolioCubit? portfolioCubit;
  CoinCubit? coinCubit;
  User? currentUser;

  AuthCubit(this.authRepository) : super(AuthInitial());

  /// Set portfolio cubit reference for loading portfolio on auth
  void setPortfolioCubit(PortfolioCubit cubit) {
    portfolioCubit = cubit;
  }

  /// Set coin cubit reference for loading coins on auth
  void setCoinCubit(CoinCubit cubit) {
    coinCubit = cubit;
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
        // Load portfolio and coins in parallel for new user
        await _initializeUserData(email);
        emit(AuthAuthenticated(currentUser!));
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
        // Load portfolio and coins in parallel for logged in user
        await _initializeUserData(email);
        emit(AuthAuthenticated(currentUser!));
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

      // Clear portfolio and coins, stop background syncs
      portfolioCubit?.clear();
      coinCubit?.setAuthorized(false);

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
          // Load portfolio and coins on app startup if user is already logged in
          portfolioCubit?.initializeUser(currentUser!.email);
          coinCubit?.setAuthorized(true);
        } else {
          emit(AuthInitial());
          coinCubit?.setAuthorized(false);
        }
      } else {
        emit(AuthInitial());
        coinCubit?.setAuthorized(false);
      }
    } catch (e) {
      emit(AuthFailure('Auth check failed: ${e.toString()}'));
    }
  }

  /// Get current user email
  String? getCurrentUserEmail() => currentUser?.email;

  /// Initialize user data: load portfolio and coins in parallel
  Future<void> _initializeUserData(String email) async {
    try {
      // Load portfolio with timeout
      final portfolioFuture = _loadPortfolioWithTimeout(email);

      await Future.wait([portfolioFuture, _loadCoinsAsync()]);
    } catch (e) {
      debugPrint('Error initializing user data: $e');
      // Don't fail the login, just log the error
    }
  }

  /// Load portfolio with timeout to prevent hanging
  Future<void> _loadPortfolioWithTimeout(String email) async {
    try {
      final portfolioLoad =
          portfolioCubit?.loadPortfolioInitial(email) ?? Future.value();

      // Add 5 second timeout to prevent hanging
      await portfolioLoad.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return;
        },
      );
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
      // Continue anyway - don't block login
    }
  }

  /// Helper to load coins asynchronously
  Future<void> _loadCoinsAsync() async {
    try {
      coinCubit?.setAuthorized(true);
    } catch (e) {
      debugPrint('Error loading coins: $e');
    }
  }
}
