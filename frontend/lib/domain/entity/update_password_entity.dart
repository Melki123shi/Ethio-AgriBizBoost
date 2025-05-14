class UpdatePasswordEntity {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  UpdatePasswordEntity({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });
}
