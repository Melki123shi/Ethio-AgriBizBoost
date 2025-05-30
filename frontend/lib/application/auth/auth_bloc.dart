import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/dto/signup_dto.dart';
import 'package:app/services/api/auth_service.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService auth;

  AuthBloc(this.auth, {bool autoStart = true}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignupSubmitted>(_onSignup);
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
    if (autoStart) {
      add(AppStarted());
    }
  }

  Future<void> _onAppStarted(AppStarted _, Emitter<AuthState> emit) async {
    final token = await TokenStorage.readAccessToken();
    if (token != null) {
      DioClient.getDio().options.headers['Authorization'] = 'Bearer $token';
      emit(AuthSuccess());
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onSignup(SignupSubmitted e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await auth.signup(SignupRequestDTO.fromEntity(e.signupData));
      emit(AuthSignupDone());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onLogin(LoginSubmitted e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final loginResp = await auth.login(
        LoginRequestDTO.fromEntity(e.loginData),
      );

      final token = loginResp.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('Login failed: no access token returned');
      }

      await TokenStorage.saveAccessToken(token);
      DioClient.getDio().options.headers['Authorization'] = 'Bearer $token';

      emit(AuthSuccess());
    } catch (err) {
      emit(AuthFailure(err.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested _, Emitter<AuthState> emit) async {
    try {
      await auth.logout();
    } catch (err) {
      // Log the error but don't fail the logout process
      // The user should be logged out locally even if server logout fails
    } finally {
      // Always clear local tokens and emit initial state
      await TokenStorage.clearAccessToken();
      DioClient.getDio().options.headers.remove('Authorization');
      emit(AuthInitial());
    }
  }
}
