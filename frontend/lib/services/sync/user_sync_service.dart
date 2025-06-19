import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app/services/local_storage/user_local_storage.dart';
import 'package:app/services/api/user_service.dart';
import 'package:app/domain/entity/update_profile_entity.dart';

class UserSyncService {
  final UserLocalStorage _localStorage = UserLocalStorage();
  final UserService _userService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  UserSyncService(this._userService);

  void startAutoSync() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncPendingChanges();
      }
    });
    _checkAndSync();
  }

  void stopAutoSync() {
    _connectivitySubscription?.cancel();
  }

  Future<void> _checkAndSync() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await syncPendingChanges();
    }
  }

  Future<bool> syncPendingChanges() async {
    try {
      if (!_localStorage.hasPendingSync()) {
        return true;
      }

      final localUser = _localStorage.getUser();
      if (localUser == null) {
        return false;
      }

      final updateData = UpdateProfileEntity(
        name: localUser.name,
        email: localUser.email,
        phoneNumber: localUser.phoneNumber,
        location: localUser.location,
      );

      await _userService.updateUserProfile(updateData);
      final serverUser = await _userService.getMe();
      await _localStorage.saveUser(serverUser);
      await _localStorage.markAsSynced();

      print('Successfully synced pending user profile changes');
      return true;
    } catch (e) {
      print('Failed to sync user profile changes: $e');
      return false;
    }
  }

  Future<SyncResult> manualSync() async {
    try {
      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        return SyncResult(
          success: false,
          message: 'No internet connection',
        );
      }

      final synced = await syncPendingChanges();
      return SyncResult(
        success: synced,
        message: synced
            ? 'Profile synced successfully'
            : 'No pending changes to sync',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: ${e.toString()}',
      );
    }
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}

class SyncResult {
  final bool success;
  final String message;

  SyncResult({required this.success, required this.message});
}
