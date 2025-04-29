class SignupInputEntity {
  final String phoneNumber;
  final String password;
  final String? name;
  final String? email;
  

  SignupInputEntity({
    required this.phoneNumber,
    required this.password,
    this.name,
    this.email,
  });
}
