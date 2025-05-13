import 'package:app/domain/entity/user_entity.dart';

class UserDTO {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? location; 

  UserDTO({this.name, this.email, this.phoneNumber, this.location});

  factory UserDTO.fromJson(Map<String, dynamic> j) => UserDTO(
        name: j['name'],
        email: j['email'],
        phoneNumber: j['phone_number'],
        location: j['location'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'location': location, 
      };

  UserEntity toEntity() => UserEntity(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        location: location, 
      );

  static UserDTO fromEntity(UserEntity e) => UserDTO(
        name: e.name,
        email: e.email,
        phoneNumber: e.phoneNumber,
        location: e.location,
      );
}
