import 'package:hive_flutter/hive_flutter.dart';
import 'package:app/domain/entity/user_entity.dart';
import 'package:app/services/local_storage/models/user_model.dart';

class UserLocalStorage {
  static const String _boxName = 'userBox';
  static const String _userKey = 'currentUser';

  late Box<UserModel> _userBox;

  // Singleton pattern
  static final UserLocalStorage _instance = UserLocalStorage._internal();
  factory UserLocalStorage() => _instance;
  UserLocalStorage._internal();

  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register the adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open the box
    _userBox = await Hive.openBox<UserModel>(_boxName);
  }

  // Save user data
  Future<void> saveUser(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    await _userBox.put(_userKey, userModel);
  }

  // Get user data
  UserEntity? getUser() {
    final userModel = _userBox.get(_userKey);
    return userModel?.toEntity();
  }

  // Update user data (marks as pending sync if offline)
  Future<void> updateUser(UserEntity user, {bool isOffline = false}) async {
    final userModel = UserModel.fromEntity(user);
    if (isOffline) {
      userModel.isPendingSync = true;
    }
    await _userBox.put(_userKey, userModel);
  }

  // Get pending sync status
  bool hasPendingSync() {
    final userModel = _userBox.get(_userKey);
    return userModel?.isPendingSync ?? false;
  }

  // Mark as synced
  Future<void> markAsSynced() async {
    final userModel = _userBox.get(_userKey);
    if (userModel != null) {
      userModel.isPendingSync = false;
      userModel.lastSyncedAt = DateTime.now();
      await userModel.save();
    }
  }

  // Clear user data
  Future<void> clearUser() async {
    await _userBox.delete(_userKey);
  }

  // Check if user exists in local storage
  bool hasUser() {
    return _userBox.containsKey(_userKey);
  }

  // Get last synced time
  DateTime? getLastSyncedTime() {
    final userModel = _userBox.get(_userKey);
    return userModel?.lastSyncedAt;
  }

  // Close the box
  Future<void> close() async {
    await _userBox.close();
  }
}
