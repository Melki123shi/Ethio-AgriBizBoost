import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/services/api/user_service.dart';
import 'package:app/application/user/user_event.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/local_storage/user_local_storage.dart';
import 'package:app/domain/entity/user_entity.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;
  final UserLocalStorage _localStorage = UserLocalStorage();

  UserBloc(this.userService) : super(UserInitial()) {
    on<AppStartedUser>(_onAppStartedUser);
    on<FetchUser>(_onFetchUser);

    on<ClearUser>((_, emit) async {
      await _localStorage.clearUser();
      emit(UserInitial());
    });
    on<UpdateUserProfile>(_onUpdateProfile);
    on<UpdateUserPassword>(_onUpdatePassword);
    add(AppStartedUser());
  }

  Future<void> _onAppStartedUser(
      AppStartedUser _, Emitter<UserState> emit) async {
    final hasAuth = DioClient.getDio().options.headers['Authorization'] != null;
    if (!hasAuth) return;

    // First, try to load from local storage
    final localUser = _localStorage.getUser();
    if (localUser != null) {
      emit(UserLoaded(localUser));

      // Then try to sync with server in background
      try {
        final user = await userService.getMe();
        await _localStorage.saveUser(user);
        emit(UserLoaded(user));
      } catch (err) {
        // If sync fails, keep using local data
        print('Failed to sync user data: $err');
      }
    } else {
      // No local data, fetch from server
      emit(UserLoading());
      try {
        final user = await userService.getMe();
        await _localStorage.saveUser(user);
        emit(UserLoaded(user));
      } catch (err) {
        emit(UserError(err.toString()));
      }
    }
  }

  Future<void> _onFetchUser(FetchUser _, Emitter<UserState> emit) async {
    // First, check and emit local data if available
    final localUser = _localStorage.getUser();
    if (localUser != null) {
      emit(UserLoaded(localUser));
    } else {
      emit(UserLoading());
    }

    // Try to fetch from server
    try {
      final user = await userService.getMe();
      await _localStorage.saveUser(user);
      emit(UserLoaded(user));

      // If there were pending changes, sync them now
      if (_localStorage.hasPendingSync()) {
        await _localStorage.markAsSynced();
      }
    } catch (err) {
      // If we have local data, keep using it
      if (localUser != null) {
        print('Failed to fetch user from server, using local data: $err');
      } else {
        emit(UserError(err.toString()));
      }
    }
  }

  Future<void> _onUpdateProfile(
      UpdateUserProfile e, Emitter<UserState> emit) async {
    emit(UserLoading());

    // Create updated user entity from local data
    final currentUser = _localStorage.getUser();
    if (currentUser == null) {
      emit(UserError('No user data found'));
      return;
    }

    // Apply updates to create new user entity
    final updatedUser = UserEntity(
      phoneNumber: e.data.phoneNumber ?? currentUser.phoneNumber,
      name: e.data.name ?? currentUser.name,
      email: e.data.email ?? currentUser.email,
      profilePictureUrl: currentUser.profilePictureUrl,
      location: e.data.location ?? currentUser.location,
    );

    try {
      // Try to update on server
      await userService.updateUserProfile(e.data);
      final user = await userService.getMe();
      await _localStorage.saveUser(user);
      emit(UserLoaded(user));
    } catch (err) {
      // If server update fails, save locally and mark for sync
      await _localStorage.updateUser(updatedUser, isOffline: true);
      emit(UserLoaded(updatedUser));
      print('Profile updated locally, will sync when online: $err');
    }
  }

  Future<void> _onUpdatePassword(
      UpdateUserPassword e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await userService.updatePassword(e.data);
      emit(UserPasswordUpdated("Password successfully updated"));
    } catch (err) {
      emit(UserError(err.toString()));
    }
  }
}
