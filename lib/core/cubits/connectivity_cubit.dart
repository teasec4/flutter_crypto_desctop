import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for connectivity states
sealed class ConnectivityState {}

/// Online state
class ConnectivityOnline extends ConnectivityState {}

/// Offline state
class ConnectivityOffline extends ConnectivityState {}

/// Cubit for monitoring internet connectivity
/// Listens to connectivity changes and notifies all cubits
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;

  ConnectivityCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(ConnectivityOnline()) {
    _initConnectivity();
  }

  /// Initialize connectivity monitoring
  void _initConnectivity() {
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged
        .listen((result) {
          developer.log('ConnectivityCubit: Connectivity changed to $result');
          _checkConnectivity();
        })
        .onError((error) {
          developer.log(
            'ConnectivityCubit: Error listening to connectivity - $error',
          );
          // Assume offline on error
          _updateState(false);
        });
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline =
          result.isNotEmpty && result.first != ConnectivityResult.none;
      _updateState(isOnline);
    } catch (e) {
      developer.log('ConnectivityCubit: Error checking connectivity - $e');
      // Assume online if error (fail-open)
      _updateState(true);
    }
  }

  /// Update connectivity state
  void _updateState(bool isOnline) {
    final newState = isOnline ? ConnectivityOnline() : ConnectivityOffline();

    // Only emit if state changed
    if ((state is ConnectivityOnline) != isOnline) {
      developer.log(
        'ConnectivityCubit: State changed to ${isOnline ? 'ONLINE' : 'OFFLINE'}',
      );
      emit(newState);
    }
  }

  /// Returns true if currently online
  bool get isOnline => state is ConnectivityOnline;
}
