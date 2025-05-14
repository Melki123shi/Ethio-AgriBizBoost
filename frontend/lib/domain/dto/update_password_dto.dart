import 'package:app/domain/entity/update_password_entity.dart';

class UpdatePasswordDTO {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  UpdatePasswordDTO({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  factory UpdatePasswordDTO.fromJson(Map<String, dynamic> j) =>
      UpdatePasswordDTO(
        currentPassword: j['current_password'] ?? '',
        newPassword: j['new_password'] ?? '',
        confirmNewPassword: j['confirm_new_password'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmNewPassword,
      };

  static UpdatePasswordDTO fromEntity(UpdatePasswordEntity e) =>
      UpdatePasswordDTO(
        currentPassword: e.currentPassword,
        newPassword: e.newPassword,
        confirmNewPassword: e.confirmNewPassword,
      );

  UpdatePasswordEntity toEntity() => UpdatePasswordEntity(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
}
