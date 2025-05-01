import 'package:app/domain/entity/signup_input_entity.dart';

class SignupRequestDTO {
  final String phoneNumber;
  final String password;
  final String? name;
  final String? email;

  SignupRequestDTO({
    required this.phoneNumber,
    required this.password,
    this.name,
    required this.email,
  });

  factory SignupRequestDTO.fromJson(Map<String, dynamic> json) {
    return SignupRequestDTO(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    };
  }

  static SignupRequestDTO fromEntity(SignupInputEntity entity) {
    return SignupRequestDTO(
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  SignupInputEntity toEntity() {
    return SignupInputEntity(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
