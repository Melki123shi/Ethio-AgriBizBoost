class SignupRequestEntity {
  final String phoneNumber;
  final String password;
  final String? name;
  final String? email;

  SignupRequestEntity({
    required this.phoneNumber,
    required this.password,
    this.name,
    this.email,
  });
}

class SignupResponseEntity {
  final String userId;
  final String? message;

  SignupResponseEntity({
    required this.userId,
    this.message
  });
}
