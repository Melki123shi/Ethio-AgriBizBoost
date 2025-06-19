class UserEntity {
  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? profilePictureUrl;
  final String? location;
  final String? userId;

  UserEntity({
    this.phoneNumber,
    this.name,
    this.email,
    this.profilePictureUrl,
    this.location,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'name': name,
    'email': email,
    'profilePictureUrl': profilePictureUrl,
    'location': location,
    '_id': userId,
  };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    phoneNumber: json['phoneNumber'],
    name: json['name'],
    email: json['email'],
    profilePictureUrl: json['profilePictureUrl'],
    location: json['location'],
    userId: json['_id']
  );
}
