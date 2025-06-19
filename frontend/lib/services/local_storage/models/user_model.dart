import 'package:hive/hive.dart';
import 'package:app/domain/entity/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? phoneNumber;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? profilePictureUrl;

  @HiveField(4)
  String? location;

  @HiveField(5)
  DateTime? lastSyncedAt;

  @HiveField(6)
  bool isPendingSync;

  UserModel({
    this.phoneNumber,
    this.name,
    this.email,
    this.profilePictureUrl,
    this.location,
    this.lastSyncedAt,
    this.isPendingSync = false,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      phoneNumber: entity.phoneNumber,
      name: entity.name,
      email: entity.email,
      profilePictureUrl: entity.profilePictureUrl,
      location: entity.location,
      lastSyncedAt: DateTime.now(),
      isPendingSync: false,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      phoneNumber: phoneNumber,
      name: name,
      email: email,
      profilePictureUrl: profilePictureUrl,
      location: location,
    );
  }

  void updateFromEntity(UserEntity entity) {
    phoneNumber = entity.phoneNumber;
    name = entity.name;
    email = entity.email;
    profilePictureUrl = entity.profilePictureUrl;
    location = entity.location;
    lastSyncedAt = DateTime.now();
    isPendingSync = false;
  }
}
