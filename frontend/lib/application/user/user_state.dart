import 'package:app/domain/entity/user_entity.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserEntity user;
  UserLoaded(this.user);
}

class UserPasswordUpdated extends UserState {
  final String message;                         
  UserPasswordUpdated(this.message);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
