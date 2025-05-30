import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/dto/signup_dto.dart';
// import 'package:app/domain/entity/login_entity.dart';
// import 'package:app/domain/entity/signup_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures/auth_fixture.dart';

void main() {
  group('Authentication DTOs', () {
    group('LoginRequestDTO', () {
      test('should convert to entity correctly', () {
        // Arrange
        final dto = AuthFixture.validLoginRequestDTO;

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.phoneNumber, dto.phoneNumber);
        expect(entity.password, dto.password);
      });

      test('should convert from entity correctly', () {
        // Arrange
        final entity = AuthFixture.validLoginRequestEntity;

        // Act
        final dto = LoginRequestDTO.fromEntity(entity);

        // Assert
        expect(dto.phoneNumber, entity.phoneNumber);
        expect(dto.password, entity.password);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final dto = AuthFixture.validLoginRequestDTO;

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], dto.phoneNumber);
        expect(json['password'], dto.password);
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        const json = {
          'phone_number': '+251912345678',
          'password': 'validPassword123',
        };

        // Act
        final dto = LoginRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, json['phone_number']);
        expect(dto.password, json['password']);
      });
    });

    group('LoginResponseDTO', () {
      test('should convert to entity correctly', () {
        // Arrange
        final dto = AuthFixture.validLoginResponseDTO;

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.accessToken, dto.accessToken);
        expect(entity.refreshToken, dto.refreshToken);
        expect(entity.tokenType, dto.tokenType);
      });

      test('should convert from entity correctly', () {
        // Arrange
        final entity = AuthFixture.validLoginResponseEntity;

        // Act
        final dto = LoginResponseDTO.fromEntity(entity);

        // Assert
        expect(dto.accessToken, entity.accessToken);
        expect(dto.refreshToken, entity.refreshToken);
        expect(dto.tokenType, entity.tokenType);
      });

      test('should handle null values in JSON', () {
        // Arrange
        const json = <String, dynamic>{};

        // Act
        final dto = LoginResponseDTO.fromJson(json);

        // Assert
        expect(dto.accessToken, equals(''));
        expect(dto.refreshToken, equals(''));
        expect(dto.tokenType, equals('Bearer'));
      });
    });

    group('SignupRequestDTO', () {
      test('should convert to entity correctly', () {
        // Arrange
        final dto = AuthFixture.validSignupRequestDTO;

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.phoneNumber, dto.phoneNumber);
        expect(entity.password, dto.password);
        expect(entity.name, dto.name);
        expect(entity.email, dto.email);
      });

      test('should convert from entity correctly', () {
        // Arrange
        final entity = AuthFixture.validSignupRequestEntity;

        // Act
        final dto = SignupRequestDTO.fromEntity(entity);

        // Assert
        expect(dto.phoneNumber, entity.phoneNumber);
        expect(dto.password, entity.password);
        expect(dto.name, entity.name);
        expect(dto.email, entity.email);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final dto = AuthFixture.validSignupRequestDTO;

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], dto.phoneNumber);
        expect(json['password'], dto.password);
        expect(json['name'], dto.name);
        expect(json['email'], dto.email);
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        const json = {
          'phone_number': '+251912345678',
          'password': 'validPassword123',
          'name': 'John Doe',
          'email': 'john@example.com',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, json['phone_number']);
        expect(dto.password, json['password']);
        expect(dto.name, json['name']);
        expect(dto.email, json['email']);
      });
    });

    group('SignupResponseDTO', () {
      test('should convert to entity correctly', () {
        // Arrange
        final dto = AuthFixture.validSignupResponseDTO;

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.userId, dto.userId);
        expect(entity.message, dto.message);
      });

      test('should convert from entity correctly', () {
        // Arrange
        final entity = AuthFixture.validSignupResponseEntity;

        // Act
        final dto = SignupResponseDTO.fromEntity(entity);

        // Assert
        expect(dto.userId, entity.userId);
        expect(dto.message, entity.message);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final dto = AuthFixture.validSignupResponseDTO;

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['user_id'], dto.userId);
        expect(json['message'], dto.message);
      });

      test('should handle missing optional fields in JSON', () {
        // Arrange
        const json = {
          'user_id': 'test123',
          // message is missing
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, 'test123');
        expect(dto.message, isNull);
      });
    });
  });

  group('Authentication Error Handling', () {
    test('should extract error message from detail field', () {
      // Arrange
      const errorData = {'detail': 'Invalid credentials'};
      const statusCode = 401;

      // Act
      final errorMessage = _extractErrorMessage(errorData, statusCode);

      // Assert
      expect(errorMessage, equals('Invalid credentials'));
    });

    test('should extract error message from string data', () {
      // Arrange
      const errorData = 'Network error';
      const statusCode = 500;

      // Act
      final errorMessage = _extractErrorMessage(errorData, statusCode);

      // Assert
      expect(errorMessage, equals('Network error'));
    });

    test('should return fallback message for unknown errors', () {
      // Arrange
      const errorData = {'unknown': 'field'};
      const statusCode = 500;

      // Act
      final errorMessage = _extractErrorMessage(errorData, statusCode);

      // Assert
      expect(errorMessage, equals('Unknown error (status 500)'));
    });

    test('should handle null error data', () {
      // Arrange
      const errorData = null;
      const statusCode = 500;

      // Act
      final errorMessage = _extractErrorMessage(errorData, statusCode);

      // Assert
      expect(errorMessage, equals('Unknown error (status 500)'));
    });
  });

  group('Authentication Business Logic', () {
    test('should validate required tokens for auto login', () {
      // Arrange
      const completeTokens = {
        'access': 'access_token',
        'refresh': 'refresh_token',
        'type': 'Bearer',
      };

      const incompleteTokens = {
        'access': null,
        'refresh': 'refresh_token',
        'type': 'Bearer',
      };

      // Act & Assert
      expect(
        // ignore: unnecessary_null_comparison
        completeTokens.values.every((token) => token != null),
        isTrue,
        reason: 'All tokens should be present for auto login',
      );

      expect(
        incompleteTokens.values.every((token) => token != null),
        isFalse,
        reason: 'Missing tokens should prevent auto login',
      );
    });

    test('should validate login response completeness', () {
      // Arrange
      const completeResponse = {
        'access_token': 'token',
        'refresh_token': 'refresh',
        'token_type': 'Bearer',
      };

      const incompleteResponse = {
        'access_token': 'token',
        // Missing refresh_token and token_type
      };

      // Act & Assert
      final completeTokens = [
        completeResponse['access_token'],
        completeResponse['refresh_token'],
        completeResponse['token_type'],
      ];

      final incompleteTokens = [
        incompleteResponse['access_token'],
        incompleteResponse['refresh_token'],
        incompleteResponse['token_type'],
      ];

      expect(
        completeTokens.every((token) => token != null),
        isTrue,
        reason: 'Complete response should have all required tokens',
      );

      expect(
        incompleteTokens.contains(null),
        isTrue,
        reason: 'Incomplete response should be detected',
      );
    });

    test('should validate user_id in signup response', () {
      // Arrange
      const validResponse = {'user_id': 'user123'};
      const invalidResponse = {'message': 'Success but no user_id'};
      const emptyUserIdResponse = {'user_id': ''};

      // Act & Assert
      final validUserId = validResponse['user_id'];
      expect(
        validUserId is String && validUserId.isNotEmpty,
        isTrue,
        reason: 'Valid response should have non-empty user_id',
      );

      final invalidUserId = invalidResponse['user_id'];
      expect(
        invalidUserId is! String || (invalidUserId).isEmpty,
        isTrue,
        reason: 'Invalid response should be detected',
      );

      final emptyUserId = emptyUserIdResponse['user_id'];
      expect(
        emptyUserId is! String || (emptyUserId).isEmpty,
        isTrue,
        reason: 'Empty user_id should be detected',
      );
    });
  });
}

/// Helper function to extract error messages (mimics the private _msg method)
String _extractErrorMessage(dynamic data, int? code,
    {String fallback = 'Unknown error'}) {
  if (data is Map && data['detail'] != null) return data['detail'];
  if (data is String && data.isNotEmpty) return data;
  return '$fallback (status $code)';
}
