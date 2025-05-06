import 'package:app/domain/entity/user_entity.dart';

abstract class UserEvent {}

class FetchUser extends UserEvent {}

class UpdateUser extends UserEvent {
  final UserEntity user;

  UpdateUser(this.user);
}
