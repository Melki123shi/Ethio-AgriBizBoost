import 'package:app/domain/entity/signup_entity.dart';

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

  static SignupRequestDTO fromEntity(SignupRequestEntity entity) {
    return SignupRequestDTO(
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }
}

class SignupResponseDTO {
  final String userId;
  final String? message;

  SignupResponseDTO({
    required this.userId,
    this.message,
  });

  factory SignupResponseDTO.fromJson(Map<String, dynamic> json) {
    return SignupResponseDTO(
      userId: json['user_id'] ?? '',
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        if (message != null) 'message': message,
      };

  static SignupResponseDTO fromEntity(SignupResponseEntity e) =>
      SignupResponseDTO(userId: e.userId, message: e.message);

  SignupResponseEntity toEntity() =>
      SignupResponseEntity(userId: userId, message: message);
}
