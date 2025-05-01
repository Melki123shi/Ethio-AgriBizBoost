class UserEntity {
  final String? id;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? profilePictureUrl;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserEntity({
    this.id,
    this.phoneNumber,
    this.name,
    this.email,
    this.profilePictureUrl,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.createdAt,
    this.updatedAt,
  });
}
