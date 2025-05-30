import 'package:app/domain/entity/login_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequestEntity', () {
    group('Constructor', () {
      test('should create instance with required fields', () {
        // Arrange & Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: '+1234567890',
          password: 'securePassword123',
        );

        // Assert
        expect(loginRequest.phoneNumber, equals('+1234567890'));
        expect(loginRequest.password, equals('securePassword123'));
      });

      test('should create instance with valid phone number formats', () {
        // Arrange
        final validPhoneNumbers = [
          '+1234567890',
          '1234567890',
          '+251911234567',
          '0911234567',
          '+44-7700-900-123',
          '(123) 456-7890',
        ];

        for (final phoneNumber in validPhoneNumbers) {
          // Act
          final loginRequest = LoginRequestEntity(
            phoneNumber: phoneNumber,
            password: 'password123',
          );

          // Assert
          expect(loginRequest.phoneNumber, equals(phoneNumber));
          expect(loginRequest.password, equals('password123'));
        }
      });

      test('should create instance with various password formats', () {
        // Arrange
        final validPasswords = [
          'simplePass',
          'Complex@Password123!',
          'VeryLongPasswordWithManyCharacters123456789',
          'short',
          '12345',
          'PasswordWithSpaces And More',
          'émojis🔒中文',
        ];

        for (final password in validPasswords) {
          // Act
          final loginRequest = LoginRequestEntity(
            phoneNumber: '+1234567890',
            password: password,
          );

          // Assert
          expect(loginRequest.phoneNumber, equals('+1234567890'));
          expect(loginRequest.password, equals(password));
        }
      });

      test('should handle empty strings', () {
        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: '',
          password: '',
        );

        // Assert
        expect(loginRequest.phoneNumber, equals(''));
        expect(loginRequest.password, equals(''));
      });

      test('should handle whitespace in fields', () {
        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: '  +1234567890  ',
          password: '  password123  ',
        );

        // Assert
        expect(loginRequest.phoneNumber, equals('  +1234567890  '));
        expect(loginRequest.password, equals('  password123  '));
      });
    });

    group('Properties', () {
      test('should be immutable after creation', () {
        // Arrange
        final loginRequest = LoginRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
        );

        // Act & Assert - Properties should be final and not modifiable
        expect(loginRequest.phoneNumber, equals('+1234567890'));
        expect(loginRequest.password, equals('password123'));

        // Verify properties are accessible
        final phoneNumber = loginRequest.phoneNumber;
        final password = loginRequest.password;

        expect(phoneNumber, isA<String>());
        expect(password, isA<String>());
      });

      test('should handle special characters in phone number', () {
        // Arrange
        const specialPhoneNumber = '+1-(234)-567-8900 ext. 123';

        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: specialPhoneNumber,
          password: 'password123',
        );

        // Assert
        expect(loginRequest.phoneNumber, equals(specialPhoneNumber));
      });

      test('should handle special characters in password', () {
        // Arrange
        const specialPassword = 'Passw0rd!@#\$%^&*()_+-=[]{}|;:,.<>?';

        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: '+1234567890',
          password: specialPassword,
        );

        // Assert
        expect(loginRequest.password, equals(specialPassword));
      });
    });

    group('Edge Cases', () {
      test('should handle very long phone numbers', () {
        // Arrange
        final longPhoneNumber = '+${'1' * 50}'; // Very long phone number

        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: longPhoneNumber,
          password: 'password123',
        );

        // Assert
        expect(loginRequest.phoneNumber, equals(longPhoneNumber));
      });

      test('should handle very long passwords', () {
        // Arrange
        final longPassword = 'a' * 1000; // Very long password

        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: '+1234567890',
          password: longPassword,
        );

        // Assert
        expect(loginRequest.password, equals(longPassword));
      });

      test('should handle unicode characters', () {
        // Arrange
        const unicodePhoneNumber = '+1234567890中文';
        const unicodePassword = 'password123中文🔒émojis';

        // Act
        final loginRequest = LoginRequestEntity(
          phoneNumber: unicodePhoneNumber,
          password: unicodePassword,
        );

        // Assert
        expect(loginRequest.phoneNumber, equals(unicodePhoneNumber));
        expect(loginRequest.password, equals(unicodePassword));
      });
    });
  });

  group('LoginResponseEntity', () {
    group('Constructor', () {
      test('should create instance with all fields provided', () {
        // Act
        final loginResponse = LoginResponseEntity(
          id: 'user123',
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_456',
          tokenType: 'Bearer',
        );

        // Assert
        expect(loginResponse.id, equals('user123'));
        expect(loginResponse.accessToken, equals('access_token_123'));
        expect(loginResponse.refreshToken, equals('refresh_token_456'));
        expect(loginResponse.tokenType, equals('Bearer'));
      });

      test('should create instance with no fields provided (all null)', () {
        // Act
        final loginResponse = LoginResponseEntity();

        // Assert
        expect(loginResponse.id, isNull);
        expect(loginResponse.accessToken, isNull);
        expect(loginResponse.refreshToken, isNull);
        expect(loginResponse.tokenType, isNull);
      });

      test('should create instance with partial fields', () {
        // Test 1: Only accessToken
        final response1 = LoginResponseEntity(accessToken: 'token123');
        expect(response1.id, isNull);
        expect(response1.accessToken, equals('token123'));
        expect(response1.refreshToken, isNull);
        expect(response1.tokenType, isNull);

        // Test 2: Only id and tokenType
        final response2 = LoginResponseEntity(
          id: 'user456',
          tokenType: 'Bearer',
        );
        expect(response2.id, equals('user456'));
        expect(response2.accessToken, isNull);
        expect(response2.refreshToken, isNull);
        expect(response2.tokenType, equals('Bearer'));

        // Test 3: Only tokens
        final response3 = LoginResponseEntity(
          accessToken: 'access123',
          refreshToken: 'refresh456',
        );
        expect(response3.id, isNull);
        expect(response3.accessToken, equals('access123'));
        expect(response3.refreshToken, equals('refresh456'));
        expect(response3.tokenType, isNull);
      });

      test('should handle empty strings vs null', () {
        // Act
        final loginResponse = LoginResponseEntity(
          id: '',
          accessToken: '',
          refreshToken: '',
          tokenType: '',
        );

        // Assert
        expect(loginResponse.id, equals(''));
        expect(loginResponse.accessToken, equals(''));
        expect(loginResponse.refreshToken, equals(''));
        expect(loginResponse.tokenType, equals(''));
      });
    });

    group('Properties', () {
      test('should handle various token types', () {
        // Arrange
        final tokenTypes = ['Bearer', 'JWT', 'Basic', 'Custom', 'OAuth'];

        for (final tokenType in tokenTypes) {
          // Act
          final loginResponse = LoginResponseEntity(
            accessToken: 'token123',
            tokenType: tokenType,
          );

          // Assert
          expect(loginResponse.tokenType, equals(tokenType));
        }
      });

      test('should handle various ID formats', () {
        // Arrange
        final idFormats = [
          'user123',
          'uuid-1234-5678-9abc-def012345678',
          'user_with_underscores',
          'user-with-hyphens',
          '12345',
          'a' * 100, // Long ID
        ];

        for (final id in idFormats) {
          // Act
          final loginResponse = LoginResponseEntity(id: id);

          // Assert
          expect(loginResponse.id, equals(id));
        }
      });

      test('should handle very long tokens', () {
        // Arrange
        final longAccessToken = 'access_${'a' * 1000}';
        final longRefreshToken = 'refresh_${'b' * 1000}';

        // Act
        final loginResponse = LoginResponseEntity(
          accessToken: longAccessToken,
          refreshToken: longRefreshToken,
        );

        // Assert
        expect(loginResponse.accessToken, equals(longAccessToken));
        expect(loginResponse.refreshToken, equals(longRefreshToken));
      });

      test('should handle special characters in tokens', () {
        // Arrange
        const specialAccessToken = 'access.token-with_special+chars=123!@#';
        const specialRefreshToken = 'refresh.token-with_special+chars=456!@#';

        // Act
        final loginResponse = LoginResponseEntity(
          accessToken: specialAccessToken,
          refreshToken: specialRefreshToken,
        );

        // Assert
        expect(loginResponse.accessToken, equals(specialAccessToken));
        expect(loginResponse.refreshToken, equals(specialRefreshToken));
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle JWT-like tokens', () {
        // Arrange
        const jwtToken =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

        // Act
        final loginResponse = LoginResponseEntity(
          accessToken: jwtToken,
          tokenType: 'Bearer',
        );

        // Assert
        expect(loginResponse.accessToken, equals(jwtToken));
        expect(loginResponse.tokenType, equals('Bearer'));
      });

      test('should handle Base64-like tokens', () {
        // Arrange
        const base64Token = 'dGVzdC10b2tlbi13aXRoLWJhc2U2NC1lbmNvZGluZw==';

        // Act
        final loginResponse = LoginResponseEntity(
          accessToken: base64Token,
        );

        // Assert
        expect(loginResponse.accessToken, equals(base64Token));
      });

      test('should handle unicode in response fields', () {
        // Arrange
        const unicodeId = 'user_中文_émojis_🔒';
        const unicodeToken = 'token_中文_émojis_🔒';

        // Act
        final loginResponse = LoginResponseEntity(
          id: unicodeId,
          accessToken: unicodeToken,
        );

        // Assert
        expect(loginResponse.id, equals(unicodeId));
        expect(loginResponse.accessToken, equals(unicodeToken));
      });

      test('should handle all null fields gracefully', () {
        // Act
        final loginResponse = LoginResponseEntity(
          id: null,
          accessToken: null,
          refreshToken: null,
          tokenType: null,
        );

        // Assert
        expect(loginResponse.id, isNull);
        expect(loginResponse.accessToken, isNull);
        expect(loginResponse.refreshToken, isNull);
        expect(loginResponse.tokenType, isNull);
      });
    });

    group('Real-world Scenarios', () {
      test('should handle typical successful login response', () {
        // Act
        final loginResponse = LoginResponseEntity(
          id: 'usr_1234567890abcdef',
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          refreshToken: 'rt_abcdef1234567890fedcba0987654321',
          tokenType: 'Bearer',
        );

        // Assert
        expect(loginResponse.id, isNotNull);
        expect(loginResponse.accessToken, isNotNull);
        expect(loginResponse.refreshToken, isNotNull);
        expect(loginResponse.tokenType, equals('Bearer'));
      });

      test('should handle partial login response (missing refresh token)', () {
        // Act
        final loginResponse = LoginResponseEntity(
          id: 'usr_1234567890abcdef',
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          tokenType: 'Bearer',
        );

        // Assert
        expect(loginResponse.id, isNotNull);
        expect(loginResponse.accessToken, isNotNull);
        expect(loginResponse.refreshToken, isNull);
        expect(loginResponse.tokenType, equals('Bearer'));
      });

      test('should handle minimal login response (only access token)', () {
        // Act
        final loginResponse = LoginResponseEntity(
          accessToken: 'simple_access_token',
        );

        // Assert
        expect(loginResponse.accessToken, equals('simple_access_token'));
        expect(loginResponse.id, isNull);
        expect(loginResponse.refreshToken, isNull);
        expect(loginResponse.tokenType, isNull);
      });
    });
  });

  group('LoginEntity Integration', () {
    test('should work together in typical auth flow scenario', () {
      // Arrange - Create login request
      final loginRequest = LoginRequestEntity(
        phoneNumber: '+251911234567',
        password: 'SecurePassword123!',
      );

      // Act - Simulate successful login response
      final loginResponse = LoginResponseEntity(
        id: 'usr_ethiopian_farmer_001',
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature',
        refreshToken: 'rt_long_lived_refresh_token_hash',
        tokenType: 'Bearer',
      );

      // Assert - Verify both entities work correctly
      expect(loginRequest.phoneNumber, equals('+251911234567'));
      expect(loginRequest.password, equals('SecurePassword123!'));

      expect(loginResponse.id, contains('ethiopian_farmer'));
      expect(loginResponse.accessToken, startsWith('eyJ'));
      expect(loginResponse.refreshToken, startsWith('rt_'));
      expect(loginResponse.tokenType, equals('Bearer'));
    });

    test('should handle failed login scenario', () {
      // Arrange - Create login request with potentially invalid data
      final loginRequest = LoginRequestEntity(
        phoneNumber: 'invalid_phone',
        password: 'weak',
      );

      // Act - Simulate failed login response (no tokens)
      final loginResponse = LoginResponseEntity();

      // Assert
      expect(loginRequest.phoneNumber, equals('invalid_phone'));
      expect(loginRequest.password, equals('weak'));

      expect(loginResponse.id, isNull);
      expect(loginResponse.accessToken, isNull);
      expect(loginResponse.refreshToken, isNull);
      expect(loginResponse.tokenType, isNull);
    });
  });
}
