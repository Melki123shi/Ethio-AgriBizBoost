import 'package:app/domain/entity/update_profile_entity.dart';

class UpdateProfileDTO {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? location;

  UpdateProfileDTO({
    this.name,
    this.email,
    this.phoneNumber,
    this.location,
  });

  factory UpdateProfileDTO.fromJson(Map<String, dynamic> j) => UpdateProfileDTO(
        name: j['name'],
        email: j['email'],
        phoneNumber: j['phone_number'],
        location: j['location'],
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (location != null) 'location': location,
      };

  static UpdateProfileDTO fromEntity(UpdateProfileEntity e) => UpdateProfileDTO(
        name: e.name,
        email: e.email,
        phoneNumber: e.phoneNumber,
        location: e.location,
      );

  UpdateProfileEntity toEntity() => UpdateProfileEntity(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        location: location,
      );
}
