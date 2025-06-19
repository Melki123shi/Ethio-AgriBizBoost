import 'package:app/domain/entity/user_entity.dart';

class UserDTO {
  final String? userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? location; 

  UserDTO({this.name, this.email, this.phoneNumber, this.location, this.userId});

  factory UserDTO.fromJson(Map<String, dynamic> j) => UserDTO(
        name: j['name'],
        email: j['email'],
        phoneNumber: j['phone_number'],
        location: j['location'],
        userId: j['_id']
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'location': location, 
        '_id': userId,
      };

  UserEntity toEntity() => UserEntity(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        location: location, 
        userId: userId,
      );

  static UserDTO fromEntity(UserEntity e) => UserDTO(
        name: e.name,
        email: e.email,
        phoneNumber: e.phoneNumber,
        location: e.location,
        userId: e.userId,
      );
}
