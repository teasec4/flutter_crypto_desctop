import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_desctop/core/constants/app_constants.dart';
import 'package:crypto_desctop/data/datasource/auth_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/user_model.dart' as user_model;
import 'dart:developer' as developer;

/// Supabase Auth Implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  Future<user_model.User> _registerWithRetry(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final response = await _supabase.auth
          .signUp(email: email, password: password)
          .timeout(
            AppConstants.networkTimeout,
            onTimeout: () => throw TimeoutException(
              'Registration timeout after ${AppConstants.networkTimeout.inSeconds}s',
            ),
          );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Failed to create user account');
      }

      final user = user_model.User(
        id: supabaseUser.id,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      // Save user profile to users table
      try {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'display_name': user.displayName,
          'created_at': user.createdAt.toIso8601String(),
        });
      } catch (e) {
        developer.log('Error saving to profiles table: $e');
        // Continue even if profile save fails
      }

      developer.log('User registered successfully: ${user.email}');
      return user;
    } on AuthException catch (e) {
      developer.log('Supabase auth error: ${e.message}');

      String errorMessage = 'Registration failed';

      if (e.message.contains('already registered')) {
        errorMessage = 'This email is already registered';
      } else if (e.message.contains('invalid email')) {
        errorMessage = 'Invalid email address';
      } else if (e.message.contains('password')) {
        errorMessage = 'Password is too weak';
      } else {
        errorMessage = 'Registration failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('Unexpected error during registration: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<user_model.User> register(
    String email,
    String password,
    String displayName,
  ) async {
    return _registerWithRetry(email, password, displayName);
  }

  Future<user_model.User> _loginWithRetry(String email, String password) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password)
          .timeout(
            AppConstants.networkTimeout,
            onTimeout: () => throw TimeoutException(
              'Login timeout after ${AppConstants.networkTimeout.inSeconds}s',
            ),
          );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Failed to login');
      }

      developer.log('User logged in successfully: ${supabaseUser.email}');

      final createdAt = DateTime.parse(supabaseUser.createdAt);

      return user_model.User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        displayName: supabaseUser.userMetadata?['display_name'] ?? '',
        createdAt: createdAt,
      );
    } on AuthException catch (e) {
      developer.log('Supabase login error: ${e.message}');

      String errorMessage = 'Login failed';

      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (e.message.contains('email')) {
        errorMessage = 'Invalid email address';
      } else if (e.message.contains('disabled')) {
        errorMessage = 'This account has been disabled';
      } else {
        errorMessage = 'Login failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('Unexpected error during login: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<user_model.User> login(String email, String password) async {
    return _loginWithRetry(email, password);
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<user_model.User?> getCurrentUser() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser == null) return null;

      final createdAt = DateTime.parse(supabaseUser.createdAt);

      return user_model.User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        displayName: supabaseUser.userMetadata?['display_name'] ?? '',
        createdAt: createdAt,
      );
    } catch (e) {
      throw Exception('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return _supabase.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }
}
