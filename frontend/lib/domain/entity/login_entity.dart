class LoginRequestEntity {
  final String phoneNumber;
  final String password;

  LoginRequestEntity({
    required this.phoneNumber,
    required this.password,
  });
}

class LoginResponseEntity {
  final String? id;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;

  LoginResponseEntity({
    this.id,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
  });
}
