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

      // Try to verify token is still valid
      try {
        // Test the token by making a simple request
        final loginEntity = await auth.tryAutoLogin();
        if (loginEntity != null) {
          emit(AuthSuccess());
        } else {
          // Token exists but auto-login failed
          await TokenStorage.clearAccessToken();
          await TokenStorage.clearRefreshToken();
          await TokenStorage.clearTokenType();
          DioClient.getDio().options.headers.remove('Authorization');
          emit(AuthInitial());
        }
      } catch (_) {
        // Any error means we should clear tokens and go to login
        await TokenStorage.clearAccessToken();
        await TokenStorage.clearRefreshToken();
        await TokenStorage.clearTokenType();
        DioClient.getDio().options.headers.remove('Authorization');
        emit(AuthInitial());
      }
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
      final message = _extractErrorMessage(err);
      emit(AuthFailure(message));
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

      // Note: The auth.login method already saves all tokens via _writeTokens
      // We just need to update the Dio header here
      DioClient.getDio().options.headers['Authorization'] = 'Bearer $token';

      emit(AuthSuccess());
    } catch (err) {
      final message = _extractErrorMessage(err);
      emit(AuthFailure(message));
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
      // Note: auth.logout() already clears all tokens, but we ensure it here too
      await TokenStorage.clearAccessToken();
      await TokenStorage.clearRefreshToken();
      await TokenStorage.clearTokenType();
      DioClient.getDio().options.headers.remove('Authorization');
      emit(AuthInitial());
    }
  }

  String _extractErrorMessage(dynamic err) {
    final errorString = err.toString();
    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    return errorString;
  }
}
