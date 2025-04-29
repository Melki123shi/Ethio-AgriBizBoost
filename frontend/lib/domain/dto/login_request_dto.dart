import 'package:app/domain/entity/login_input_entity.dart';

class LoginRequestDTO {
  final String phoneNumber;
  final String password;

  LoginRequestDTO({
    required this.phoneNumber,
    required this.password,
  });

  factory LoginRequestDTO.fromJson(Map<String, dynamic> json) {
    return LoginRequestDTO(
      phoneNumber: json['phone_number'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
    };
  }

  static LoginRequestDTO fromEntity(LoginInputEntity entity) {
    return LoginRequestDTO(
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  LoginInputEntity toEntity() {
    return LoginInputEntity(
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
