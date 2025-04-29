class UserEntity {
  final String id;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? profilePictureUrl;
  final String? token;
  final List<String>? roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserEntity({
    required this.id,
    this.phoneNumber,
    this.name,
    this.email,
    this.profilePictureUrl,
    this.token,
    this.roles,
    this.createdAt,
    this.updatedAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      name: json['name'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      token: json['token'],
      roles: _parseRoles(json['roles']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static List<String>? _parseRoles(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
