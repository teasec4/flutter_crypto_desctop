import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto_desctop/core/constants/app_constants.dart';
import 'package:crypto_desctop/data/datasource/portfolio_remote_datasource.dart';
import 'package:crypto_desctop/domain/models/portfolio_item.dart';

class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final SupabaseClient _supabase;

  PortfolioRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<PortfolioItem>> getPortfolioItems(String userEmail) async {
    try {
      // Get current user ID from auth
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from(AppConstants.portfolioTable)
          .select()
          .eq('user_id', userId)
          .timeout(AppConstants.networkTimeout, onTimeout: () {
        throw TimeoutException(
          'Timeout while fetching portfolio items after ${AppConstants.networkTimeout.inSeconds}s',
        );
      });

      return (response as List)
          .map((item) => PortfolioItem.fromJson(item))
          .toList();
    } catch (e) {
      developer.log('PortfolioRemoteDataSource: getPortfolioItems error: $e');
      throw Exception('Failed to get portfolio items: ${e.toString()}');
    }
  }

  @override
  Future<void> addPortfolioItem(String userEmail, PortfolioItem item) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from(AppConstants.portfolioTable)
          .insert({
            'user_id': userId,
            'symbol': item.symbol,
            'amount': item.amount,
            'added_at': item.addedAt.toIso8601String(),
          })
          .timeout(AppConstants.networkTimeout, onTimeout: () {
        throw TimeoutException(
          'Timeout while adding portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
        );
      });
    } catch (e) {
      developer.log('PortfolioRemoteDataSource: addPortfolioItem error: $e');
      throw Exception('Failed to add portfolio item: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePortfolioItemAmount(
    String userEmail,
    String itemId,
    double newAmount,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from(AppConstants.portfolioTable)
          .update({'amount': newAmount})
          .eq('symbol', itemId)
          .eq('user_id', userId)
          .timeout(AppConstants.networkTimeout, onTimeout: () {
        throw TimeoutException(
          'Timeout while updating portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
        );
      });
    } catch (e) {
      developer.log('PortfolioRemoteDataSource: updatePortfolioItemAmount error: $e');
      throw Exception('Failed to update portfolio item: ${e.toString()}');
    }
  }

  @override
  Future<void> removePortfolioItem(String userEmail, String itemId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from(AppConstants.portfolioTable)
          .delete()
          .eq('symbol', itemId)
          .eq('user_id', userId)
          .timeout(AppConstants.networkTimeout, onTimeout: () {
        throw TimeoutException(
          'Timeout while removing portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
        );
      });
    } catch (e) {
      developer.log('PortfolioRemoteDataSource: removePortfolioItem error: $e');
      throw Exception('Failed to remove portfolio item: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUserPortfolio(String userEmail) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from(AppConstants.portfolioTable)
          .delete()
          .eq('user_id', userId)
          .timeout(AppConstants.networkTimeout, onTimeout: () {
        throw TimeoutException(
          'Timeout while clearing portfolio after ${AppConstants.networkTimeout.inSeconds}s',
        );
      });
    } catch (e) {
      developer.log('PortfolioRemoteDataSource: clearUserPortfolio error: $e');
      throw Exception('Failed to clear portfolio: ${e.toString()}');
    }
  }
}
