import 'package:app/domain/entity/login_entity.dart';

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

  static LoginRequestDTO fromEntity(LoginRequestEntity entity) {
    return LoginRequestDTO(
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  LoginRequestEntity toEntity() {
    return LoginRequestEntity(
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}

class LoginResponseDTO {
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;

  LoginResponseDTO({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) =>
      LoginResponseDTO(
        accessToken: json['access_token'] ?? '',
        refreshToken: json['refresh_token'] ?? '',
        tokenType: json['token_type'] ?? 'Bearer',
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
      };

  static LoginResponseDTO fromEntity(LoginResponseEntity e) => LoginResponseDTO(
        accessToken: e.accessToken,
        refreshToken: e.refreshToken,
        tokenType: e.tokenType,
      );

  LoginResponseEntity toEntity() => LoginResponseEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
      );
}
