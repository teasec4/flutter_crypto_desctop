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
          .timeout(
            AppConstants.networkTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Timeout while fetching portfolio items after ${AppConstants.networkTimeout.inSeconds}s',
              );
            },
          );

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

      developer.log(
        'PortfolioRemoteDataSource: Adding/updating item ${item.symbol} with amount ${item.amount}',
      );

      // First, check if this symbol already exists for this user
      final existingItem = await _supabase
          .from(AppConstants.portfolioTable)
          .select('id, amount')
          .eq('symbol', item.symbol)
          .eq('user_id', userId)
          .timeout(
            AppConstants.networkTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Timeout while checking existing portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
              );
            },
          );

      if (existingItem.isNotEmpty) {
        // Item with this symbol exists - add new amount to existing amount
        final existingId = existingItem[0]['id'] as String;
        final currentAmount =
            (existingItem[0]['amount'] as num?)?.toDouble() ?? 0.0;
        final newTotalAmount = currentAmount + item.amount;

        developer.log(
          'PortfolioRemoteDataSource: ${item.symbol} EXISTS with id=$existingId, amount=$currentAmount, adding ${item.amount} → total $newTotalAmount',
        );

        await _supabase
            .from(AppConstants.portfolioTable)
            .update({'amount': newTotalAmount})
            .eq('id', existingId)
            .eq('user_id', userId)
            .timeout(
              AppConstants.networkTimeout,
              onTimeout: () {
                throw TimeoutException(
                  'Timeout while updating portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
                );
              },
            );
      } else {
        // Item doesn't exist - create new record with UUID
        developer.log(
          'PortfolioRemoteDataSource: ${item.symbol} is NEW, creating record with id=${item.id}, amount=${item.amount}',
        );

        await _supabase
            .from(AppConstants.portfolioTable)
            .insert({
              'id': item.id,
              'user_id': userId,
              'symbol': item.symbol,
              'amount': item.amount,
              'added_at': item.addedAt.toIso8601String(),
            })
            .timeout(
              AppConstants.networkTimeout,
              onTimeout: () {
                throw TimeoutException(
                  'Timeout while adding portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
                );
              },
            );
      }

      developer.log(
        'PortfolioRemoteDataSource: Item ${item.symbol} added/updated successfully',
      );
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

      developer.log(
        'PortfolioRemoteDataSource: Updating item $itemId with amount $newAmount',
      );

      await _supabase
          .from(AppConstants.portfolioTable)
          .update({'amount': newAmount})
          .eq('id', itemId)
          .eq('user_id', userId)
          .timeout(
            AppConstants.networkTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Timeout while updating portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
              );
            },
          );

      developer.log(
        'PortfolioRemoteDataSource: Item $itemId updated successfully',
      );
    } catch (e) {
      developer.log(
        'PortfolioRemoteDataSource: updatePortfolioItemAmount error: $e',
      );
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

      developer.log('PortfolioRemoteDataSource: Deleting item $itemId');

      await _supabase
          .from(AppConstants.portfolioTable)
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId)
          .timeout(
            AppConstants.networkTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Timeout while removing portfolio item after ${AppConstants.networkTimeout.inSeconds}s',
              );
            },
          );

      developer.log(
        'PortfolioRemoteDataSource: Item $itemId deleted successfully',
      );
    } catch (e) {
      developer.log('PortfolioRemoteDataSource: removePortfolioItem error: $e');
      throw Exception('Failed to remove portfolio item: ${e.toString()}');
    }
  }

}
