import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/services/api/user_service.dart';
import 'package:app/application/user/user_event.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/services/network/dio_client.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc(this.userService) : super(UserInitial()) {
    on<AppStartedUser>(_onAppStartedUser);
    on<FetchUser>(_onFetchUser);

    on<ClearUser>((_, emit) => emit(UserInitial()));
    on<UpdateUserProfile>(_onUpdateProfile);
    on<UpdateUserPassword>(_onUpdatePassword);
    add(AppStartedUser());
  }

  Future<void> _onAppStartedUser(AppStartedUser _, Emitter<UserState> emit) async {
    final hasAuth = DioClient.getDio().options.headers['Authorization'] != null;
    if (!hasAuth) return;

    emit(UserLoading());
    try {
      final user = await userService.getMe();
      emit(UserLoaded(user));
    } catch (err) {
      emit(UserError(err.toString()));
    }
  }

  Future<void> _onFetchUser(FetchUser _, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await userService.getMe();
      emit(UserLoaded(user));
    } catch (err) {
      emit(UserError(err.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateUserProfile e, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await userService.updateUserProfile(e.data);
      final user = await userService.getMe();
      emit(UserLoaded(user));
    } catch (err) {
      emit(UserError(err.toString()));
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
