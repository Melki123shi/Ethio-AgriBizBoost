import 'package:app/domain/entity/user_entity.dart';

class UserDTO {
  final String? id;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? profilePictureUrl;
  final String? location;
  final String? job;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserDTO({
    this.id,
    this.phoneNumber,
    this.name,
    this.email,
    this.profilePictureUrl,
    this.location,
    this.job,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      phoneNumber: json['phone_number'],
      name: json['name'],
      email: json['email'],
      profilePictureUrl: json['profile_picture_url'],
      location: json['location'],
      job: json['job'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'profile_picture_url': profilePictureUrl,
      'location': location,
      'job': job,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static UserDTO fromEntity(UserEntity entity) {
    return UserDTO(
      id: entity.id,
      phoneNumber: entity.phoneNumber,
      name: entity.name,
      email: entity.email,
      profilePictureUrl: entity.profilePictureUrl,
      location: entity.location,
      job: entity.job,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      tokenType: entity.tokenType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      phoneNumber: phoneNumber,
      name: name,
      email: email,
      profilePictureUrl: profilePictureUrl,
      location: location,
      job: job,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
