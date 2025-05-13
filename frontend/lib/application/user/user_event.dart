import 'package:app/domain/entity/update_profile_entity.dart';
import 'package:app/domain/entity/update_password_entity.dart';

abstract class UserEvent {}

class FetchUser extends UserEvent {}

class ClearUser extends UserEvent {}

class AppStartedUser extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final UpdateProfileEntity data;
  UpdateUserProfile(this.data);
}

class UpdateUserPassword extends UserEvent {
  final UpdatePasswordEntity data;
  UpdateUserPassword(this.data);
}
