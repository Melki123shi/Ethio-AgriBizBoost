import 'package:app/domain/dto/login_request_dto.dart';
import 'package:app/domain/dto/signup_request_dto.dart';
import 'package:app/services/api/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final dto = SignupRequestDTO.fromEntity(event.signupData);
      final user = await authService.signup(dto);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure('Signup failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final dto = LoginRequestDTO.fromEntity(event.loginData);
      final user = await authService.login(dto);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
    }
  }
}
