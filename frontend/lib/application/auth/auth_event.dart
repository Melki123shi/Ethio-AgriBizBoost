import 'package:equatable/equatable.dart';
import 'package:app/domain/entity/signup_input_entity.dart';
import 'package:app/domain/entity/login_input_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignupSubmitted extends AuthEvent {
  final SignupInputEntity signupData;

  const SignupSubmitted({required this.signupData});

  @override
  List<Object?> get props => [signupData];
}

class LoginSubmitted extends AuthEvent {
  final LoginInputEntity loginData;

  const LoginSubmitted({required this.loginData});

  @override
  List<Object?> get props => [loginData];
}
