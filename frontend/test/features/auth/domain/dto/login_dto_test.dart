import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/entity/login_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequestDTO', () {
    group('Constructor', () {
      test('should create LoginRequestDTO with required fields', () {
        // Act
        final dto = LoginRequestDTO(
          phoneNumber: '+251911234567',
          password: 'securePassword123',
        );

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('securePassword123'));
      });

      test('should create LoginRequestDTO with Ethiopian phone number', () {
        // Act
        final dto = LoginRequestDTO(
          phoneNumber: '+251922123456',
          password: 'farmerPass@2023',
        );

        // Assert
        expect(dto.phoneNumber, equals('+251922123456'));
        expect(dto.password, equals('farmerPass@2023'));
      });

      test('should create LoginRequestDTO with local phone format', () {
        // Act
        final dto = LoginRequestDTO(
          phoneNumber: '0911234567',
          password: 'localPassword',
        );

        // Assert
        expect(dto.phoneNumber, equals('0911234567'));
        expect(dto.password, equals('localPassword'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final dto = LoginRequestDTO(
          phoneNumber: '+251911234567',
          password: 'testPassword123',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'phone_number': '+251911234567',
          'password': 'testPassword123',
        });
      });

      test('should serialize Ethiopian phone numbers correctly', () {
        // Arrange
        final dto = LoginRequestDTO(
          phoneNumber: '+251933987654',
          password: 'አማርኛPassword',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], equals('+251933987654'));
        expect(json['password'], equals('አማርኛPassword'));
      });

      test('should serialize with special characters in password', () {
        // Arrange
        final dto = LoginRequestDTO(
          phoneNumber: '+251911123456',
          password: 'Complex@Pass#2023!',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['password'], equals('Complex@Pass#2023!'));
      });

      test('should serialize empty strings correctly', () {
        // Arrange
        final dto = LoginRequestDTO(
          phoneNumber: '',
          password: '',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], equals(''));
        expect(json['password'], equals(''));
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'phone_number': '+251911234567',
          'password': 'testPassword123',
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('testPassword123'));
      });

      test('should deserialize with missing phone_number field', () {
        // Arrange
        final json = {
          'password': 'testPassword123',
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals(''));
        expect(dto.password, equals('testPassword123'));
      });

      test('should deserialize with missing password field', () {
        // Arrange
        final json = {
          'phone_number': '+251911234567',
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals(''));
      });

      test('should deserialize with null values', () {
        // Arrange
        final json = {
          'phone_number': null,
          'password': null,
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals(''));
        expect(dto.password, equals(''));
      });

      test('should deserialize with extra fields', () {
        // Arrange
        final json = {
          'phone_number': '+251911234567',
          'password': 'testPassword123',
          'extra_field': 'ignored',
          'another_field': 42,
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('testPassword123'));
      });

      test('should deserialize Ethiopian phone numbers', () {
        // Arrange
        final json = {
          'phone_number': '+251944556677',
          'password': 'የገበያPassword',
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251944556677'));
        expect(dto.password, equals('የገበያPassword'));
      });
    });

    group('Entity Conversion', () {
      test('should convert from entity correctly', () {
        // Arrange
        final entity = LoginRequestEntity(
          phoneNumber: '+251911234567',
          password: 'entityPassword',
        );

        // Act
        final dto = LoginRequestDTO.fromEntity(entity);

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('entityPassword'));
      });

      test('should convert to entity correctly', () {
        // Arrange
        final dto = LoginRequestDTO(
          phoneNumber: '+251933123456',
          password: 'dtoPassword',
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.phoneNumber, equals('+251933123456'));
        expect(entity.password, equals('dtoPassword'));
      });

      test('should maintain data integrity during round-trip conversion', () {
        // Arrange
        final originalEntity = LoginRequestEntity(
          phoneNumber: '+251922998877',
          password: 'roundTripPassword!@#',
        );

        // Act
        final dto = LoginRequestDTO.fromEntity(originalEntity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.phoneNumber, equals(originalEntity.phoneNumber));
        expect(convertedEntity.password, equals(originalEntity.password));
      });

      test('should handle empty values in entity conversion', () {
        // Arrange
        final entity = LoginRequestEntity(
          phoneNumber: '',
          password: '',
        );

        // Act
        final dto = LoginRequestDTO.fromEntity(entity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.phoneNumber, equals(''));
        expect(convertedEntity.password, equals(''));
      });
    });

    group('Ethiopian Agriculture Context', () {
      test('should handle farmer login credentials', () {
        // Arrange
        final dto = LoginRequestDTO(
          phoneNumber: '+251912345678',
          password: 'FarmerTeff2023',
        );

        // Act
        final json = dto.toJson();
        final entity = dto.toEntity();

        // Assert
        expect(json['phone_number'], equals('+251912345678'));
        expect(entity.phoneNumber, equals('+251912345678'));
        expect(entity.password, equals('FarmerTeff2023'));
      });

      test('should handle cooperative member credentials', () {
        // Arrange
        final json = {
          'phone_number': '+251933567890',
          'password': 'CoopCoffee@Sidama',
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251933567890'));
        expect(dto.password, equals('CoopCoffee@Sidama'));
      });

      test('should handle agricultural advisor credentials', () {
        // Arrange
        final entity = LoginRequestEntity(
          phoneNumber: '+251944123789',
          password: 'AdvisorOromia123',
        );

        // Act
        final dto = LoginRequestDTO.fromEntity(entity);
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], equals('+251944123789'));
        expect(json['password'], equals('AdvisorOromia123'));
      });
    });
  });

  group('LoginResponseDTO', () {
    group('Constructor', () {
      test('should create LoginResponseDTO with all fields', () {
        // Act
        final dto = LoginResponseDTO(
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          refreshToken: 'refresh_token_value',
          tokenType: 'Bearer',
        );

        // Assert
        expect(
            dto.accessToken, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'));
        expect(dto.refreshToken, equals('refresh_token_value'));
        expect(dto.tokenType, equals('Bearer'));
      });

      test('should create LoginResponseDTO with null values', () {
        // Act
        final dto = LoginResponseDTO(
          accessToken: null,
          refreshToken: null,
          tokenType: null,
        );

        // Assert
        expect(dto.accessToken, isNull);
        expect(dto.refreshToken, isNull);
        expect(dto.tokenType, isNull);
      });

      test('should create LoginResponseDTO with minimal parameters', () {
        // Act
        final dto = LoginResponseDTO();

        // Assert
        expect(dto.accessToken, isNull);
        expect(dto.refreshToken, isNull);
        expect(dto.tokenType, isNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly with all fields', () {
        // Arrange
        final dto = LoginResponseDTO(
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_456',
          tokenType: 'Bearer',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'access_token': 'access_token_123',
          'refresh_token': 'refresh_token_456',
          'token_type': 'Bearer',
        });
      });

      test('should serialize to JSON with null values', () {
        // Arrange
        final dto = LoginResponseDTO(
          accessToken: null,
          refreshToken: null,
          tokenType: null,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'access_token': null,
          'refresh_token': null,
          'token_type': null,
        });
      });

      test('should serialize JWT tokens correctly', () {
        // Arrange
        final dto = LoginResponseDTO(
          accessToken:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
          refreshToken: 'refresh_jwt_token_here',
          tokenType: 'Bearer',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['access_token'],
            contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'));
        expect(json['token_type'], equals('Bearer'));
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'access_token': 'access_token_123',
          'refresh_token': 'refresh_token_456',
          'token_type': 'Bearer',
        };

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(dto.accessToken, equals('access_token_123'));
        expect(dto.refreshToken, equals('refresh_token_456'));
        expect(dto.tokenType, equals('Bearer'));
      });

      test('should deserialize with missing fields using defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(dto.accessToken, equals(''));
        expect(dto.refreshToken, equals(''));
        expect(dto.tokenType, equals('Bearer'));
      });

      test('should deserialize with null values using defaults', () {
        // Arrange
        final json = {
          'access_token': null,
          'refresh_token': null,
          'token_type': null,
        };

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(dto.accessToken, equals(''));
        expect(dto.refreshToken, equals(''));
        expect(dto.tokenType, equals('Bearer'));
      });

      test('should deserialize with partial fields', () {
        // Arrange
        final json = {
          'access_token': 'only_access_token',
        };

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(dto.accessToken, equals('only_access_token'));
        expect(dto.refreshToken, equals(''));
        expect(dto.tokenType, equals('Bearer'));
      });

      test('should deserialize real API response format', () {
        // Arrange
        final json = {
          'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'refresh_token': 'refresh_12345',
          'token_type': 'Bearer',
          'expires_in': 3600, // Extra field that should be ignored
        };

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(
            dto.accessToken, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'));
        expect(dto.refreshToken, equals('refresh_12345'));
        expect(dto.tokenType, equals('Bearer'));
      });
    });

    group('Entity Conversion', () {
      test('should convert from entity correctly', () {
        // Arrange
        final entity = LoginResponseEntity(
          accessToken: 'entity_access_token',
          refreshToken: 'entity_refresh_token',
          tokenType: 'Bearer',
        );

        // Act
        final dto = LoginResponseDTO.fromEntity(entity);

        // Assert
        expect(dto.accessToken, equals('entity_access_token'));
        expect(dto.refreshToken, equals('entity_refresh_token'));
        expect(dto.tokenType, equals('Bearer'));
      });

      test('should convert to entity correctly', () {
        // Arrange
        final dto = LoginResponseDTO(
          accessToken: 'dto_access_token',
          refreshToken: 'dto_refresh_token',
          tokenType: 'JWT',
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.accessToken, equals('dto_access_token'));
        expect(entity.refreshToken, equals('dto_refresh_token'));
        expect(entity.tokenType, equals('JWT'));
      });

      test('should maintain data integrity during round-trip conversion', () {
        // Arrange
        final originalEntity = LoginResponseEntity(
          accessToken: 'round_trip_access',
          refreshToken: 'round_trip_refresh',
          tokenType: 'Bearer',
        );

        // Act
        final dto = LoginResponseDTO.fromEntity(originalEntity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.accessToken, equals(originalEntity.accessToken));
        expect(
            convertedEntity.refreshToken, equals(originalEntity.refreshToken));
        expect(convertedEntity.tokenType, equals(originalEntity.tokenType));
      });

      test('should handle null values in entity conversion', () {
        // Arrange
        final entity = LoginResponseEntity(
          accessToken: null,
          refreshToken: null,
          tokenType: null,
        );

        // Act
        final dto = LoginResponseDTO.fromEntity(entity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.accessToken, isNull);
        expect(convertedEntity.refreshToken, isNull);
        expect(convertedEntity.tokenType, isNull);
      });
    });

    group('Ethiopian Agriculture Context', () {
      test('should handle farmer authentication response', () {
        // Arrange
        final json = {
          'access_token': 'farmer_session_token',
          'refresh_token': 'farmer_refresh_token',
          'token_type': 'Bearer',
        };

        // Act
        final dto = LoginResponseDTO.fromJson(json);
        final entity = dto.toEntity();

        // Assert
        expect(entity.accessToken, equals('farmer_session_token'));
        expect(entity.tokenType, equals('Bearer'));
      });

      test('should handle cooperative login response', () {
        // Arrange
        final dto = LoginResponseDTO(
          accessToken: 'coop_access_token_sidama',
          refreshToken: 'coop_refresh_token',
          tokenType: 'Bearer',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['access_token'], equals('coop_access_token_sidama'));
        expect(json['token_type'], equals('Bearer'));
      });

      test('should handle failed login response', () {
        // Arrange
        final json = {
          'access_token': '',
          'refresh_token': '',
          'token_type': 'Bearer',
        };

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(dto.accessToken, equals(''));
        expect(dto.refreshToken, equals(''));
        expect(dto.tokenType, equals('Bearer'));
      });
    });
  });
}
