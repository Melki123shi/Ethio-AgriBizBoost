import 'package:app/domain/entity/signup_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignupRequestEntity', () {
    group('Constructor', () {
      test('should create instance with required fields only', () {
        // Arrange & Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'securePassword123',
        );

        // Assert
        expect(signupRequest.phoneNumber, equals('+1234567890'));
        expect(signupRequest.password, equals('securePassword123'));
        expect(signupRequest.name, isNull);
        expect(signupRequest.email, isNull);
      });

      test('should create instance with all fields provided', () {
        // Arrange & Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: '+251911234567',
          password: 'SecurePassword123!',
          name: 'John Doe',
          email: 'john.doe@example.com',
        );

        // Assert
        expect(signupRequest.phoneNumber, equals('+251911234567'));
        expect(signupRequest.password, equals('SecurePassword123!'));
        expect(signupRequest.name, equals('John Doe'));
        expect(signupRequest.email, equals('john.doe@example.com'));
      });

      test('should create instance with partial optional fields', () {
        // Test 1: Only name provided
        final request1 = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
          name: 'Alice Smith',
        );
        expect(request1.name, equals('Alice Smith'));
        expect(request1.email, isNull);

        // Test 2: Only email provided
        final request2 = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
          email: 'alice@example.com',
        );
        expect(request2.name, isNull);
        expect(request2.email, equals('alice@example.com'));
      });

      test('should handle various phone number formats', () {
        // Arrange
        final validPhoneNumbers = [
          '+1234567890',
          '1234567890',
          '+251911234567',
          '0911234567',
          '+44-7700-900-123',
          '(123) 456-7890',
          '+1 (555) 123-4567',
        ];

        for (final phoneNumber in validPhoneNumbers) {
          // Act
          final signupRequest = SignupRequestEntity(
            phoneNumber: phoneNumber,
            password: 'password123',
          );

          // Assert
          expect(signupRequest.phoneNumber, equals(phoneNumber));
        }
      });

      test('should handle various password complexities', () {
        // Arrange
        final validPasswords = [
          'simple',
          'Complex@Password123!',
          'VeryLongPasswordWithManyCharactersAndNumbers123456789',
          'short',
          'P@ssw0rd!',
          'PasswordWithSpaces And More',
          'émojis🔒中文密码',
          '12345678',
        ];

        for (final password in validPasswords) {
          // Act
          final signupRequest = SignupRequestEntity(
            phoneNumber: '+1234567890',
            password: password,
          );

          // Assert
          expect(signupRequest.password, equals(password));
        }
      });

      test('should handle various name formats', () {
        // Arrange
        final validNames = [
          'John',
          'John Doe',
          'Mary Jane Watson',
          'José María García-López',
          'Ahmed ibn Abdallah',
          'Li Wei',
          'Åse Müller',
          'Jean-Pierre',
          "O'Connor",
          'محمد الأحمد', // Arabic
          '张三', // Chinese
          'Räikkönen',
          'አበበ ድጉማ', // Amharic
          'Alemayehu Tesfaye', // Ethiopian
        ];

        for (final name in validNames) {
          // Act
          final signupRequest = SignupRequestEntity(
            phoneNumber: '+1234567890',
            password: 'password123',
            name: name,
          );

          // Assert
          expect(signupRequest.name, equals(name));
        }
      });

      test('should handle various email formats', () {
        // Arrange
        final validEmails = [
          'user@example.com',
          'first.last@domain.co.uk',
          'user+tag@example.org',
          'user_name@domain-name.com',
          'test.email123@test-domain123.co.uk',
          'very.long.email.address@very-long-domain-name.com',
          'user@localhost',
          'user@192.168.1.1',
        ];

        for (final email in validEmails) {
          // Act
          final signupRequest = SignupRequestEntity(
            phoneNumber: '+1234567890',
            password: 'password123',
            email: email,
          );

          // Assert
          expect(signupRequest.email, equals(email));
        }
      });
    });

    group('Properties', () {
      test('should be immutable after creation', () {
        // Arrange
        final signupRequest = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
          name: 'John Doe',
          email: 'john@example.com',
        );

        // Act & Assert - Properties should be final and not modifiable
        expect(signupRequest.phoneNumber, equals('+1234567890'));
        expect(signupRequest.password, equals('password123'));
        expect(signupRequest.name, equals('John Doe'));
        expect(signupRequest.email, equals('john@example.com'));

        // Verify property types
        expect(signupRequest.phoneNumber, isA<String>());
        expect(signupRequest.password, isA<String>());
        expect(signupRequest.name, isA<String?>());
        expect(signupRequest.email, isA<String?>());
      });

      test('should handle empty strings vs null for optional fields', () {
        // Test 1: Empty strings
        final request1 = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
          name: '',
          email: '',
        );
        expect(request1.name, equals(''));
        expect(request1.email, equals(''));

        // Test 2: Null values
        final request2 = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
          name: null,
          email: null,
        );
        expect(request2.name, isNull);
        expect(request2.email, isNull);
      });

      test('should handle whitespace in all fields', () {
        // Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: '  +1234567890  ',
          password: '  password123  ',
          name: '  John Doe  ',
          email: '  john@example.com  ',
        );

        // Assert - Values should be preserved as-is (no trimming)
        expect(signupRequest.phoneNumber, equals('  +1234567890  '));
        expect(signupRequest.password, equals('  password123  '));
        expect(signupRequest.name, equals('  John Doe  '));
        expect(signupRequest.email, equals('  john@example.com  '));
      });

      test('should handle special characters in all fields', () {
        // Arrange
        const specialPhoneNumber = '+1-(234)-567-8900 ext. 123';
        const specialPassword = 'Passw0rd!@#\$%^&*()_+-=[]{}|;:,.<>?';
        const specialName = "O'Connor-Smith Jr. III";
        const specialEmail = 'user+tag123@sub-domain.example-site.co.uk';

        // Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: specialPhoneNumber,
          password: specialPassword,
          name: specialName,
          email: specialEmail,
        );

        // Assert
        expect(signupRequest.phoneNumber, equals(specialPhoneNumber));
        expect(signupRequest.password, equals(specialPassword));
        expect(signupRequest.name, equals(specialName));
        expect(signupRequest.email, equals(specialEmail));
      });
    });

    group('Edge Cases', () {
      test('should handle very long field values', () {
        // Arrange
        final longPhoneNumber = '+${'1' * 50}';
        final longPassword = 'P@ssw0rd${'a' * 1000}';
        final longName = 'John ${'A' * 500} Doe';
        final longEmail = 'user${'a' * 100}@domain${'b' * 100}.com';

        // Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: longPhoneNumber,
          password: longPassword,
          name: longName,
          email: longEmail,
        );

        // Assert
        expect(signupRequest.phoneNumber, equals(longPhoneNumber));
        expect(signupRequest.password, equals(longPassword));
        expect(signupRequest.name, equals(longName));
        expect(signupRequest.email, equals(longEmail));
      });

      test('should handle unicode and international characters', () {
        // Arrange
        const unicodePhoneNumber = '+86中文123';
        const unicodePassword = 'password中文🔒émojis';
        const unicodeName = 'José María 中文 🌟 Émile';
        const unicodeEmail = 'user中文@domain中文.com';

        // Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: unicodePhoneNumber,
          password: unicodePassword,
          name: unicodeName,
          email: unicodeEmail,
        );

        // Assert
        expect(signupRequest.phoneNumber, equals(unicodePhoneNumber));
        expect(signupRequest.password, equals(unicodePassword));
        expect(signupRequest.name, equals(unicodeName));
        expect(signupRequest.email, equals(unicodeEmail));
      });

      test('should handle empty required fields', () {
        // Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: '',
          password: '',
        );

        // Assert
        expect(signupRequest.phoneNumber, equals(''));
        expect(signupRequest.password, equals(''));
        expect(signupRequest.name, isNull);
        expect(signupRequest.email, isNull);
      });

      test('should handle mixed casing in email', () {
        // Arrange
        const mixedCaseEmail = 'User.Name+Tag@Example-Domain.COM';

        // Act
        final signupRequest = SignupRequestEntity(
          phoneNumber: '+1234567890',
          password: 'password123',
          email: mixedCaseEmail,
        );

        // Assert - Email should be preserved as-is
        expect(signupRequest.email, equals(mixedCaseEmail));
      });
    });

    group('Business Logic Scenarios', () {
      test('should handle Ethiopian phone number format', () {
        // Arrange
        final ethiopianNumbers = [
          '+251911234567',
          '+251912345678',
          '0911234567',
          '0923456789',
        ];

        for (final phoneNumber in ethiopianNumbers) {
          // Act
          final signupRequest = SignupRequestEntity(
            phoneNumber: phoneNumber,
            password: 'SecurePass123!',
            name: 'Farmer John',
          );

          // Assert
          expect(signupRequest.phoneNumber, equals(phoneNumber));
        }
      });

      test('should handle agricultural business names', () {
        // Arrange
        final businessNames = [
          'Addis Farms Ltd.',
          'Ethiopian Coffee Cooperative',
          'Teff & Grain Trading Co.',
          'Highland Agriculture Solutions',
          'Rift Valley Livestock Association',
        ];

        for (final name in businessNames) {
          // Act
          final signupRequest = SignupRequestEntity(
            phoneNumber: '+251911234567',
            password: 'SecurePass123!',
            name: name,
          );

          // Assert
          expect(signupRequest.name, equals(name));
        }
      });

      test('should handle farmer profile creation', () {
        // Act
        final farmerSignup = SignupRequestEntity(
          phoneNumber: '+251911234567',
          password: 'SecureFarmerPass123!',
          name: 'Tekle Berhan',
          email: 'tekle.berhan@agri.et',
        );

        // Assert
        expect(farmerSignup.phoneNumber, contains('+251'));
        expect(farmerSignup.password, contains('Secure'));
        expect(farmerSignup.name, contains('Tekle'));
        expect(farmerSignup.email, contains('@agri.et'));
      });
    });
  });

  group('SignupResponseEntity', () {
    group('Constructor', () {
      test('should create instance with required userId', () {
        // Act
        final signupResponse = SignupResponseEntity(
          userId: 'usr_12345',
        );

        // Assert
        expect(signupResponse.userId, equals('usr_12345'));
        expect(signupResponse.message, isNull);
      });

      test('should create instance with userId and message', () {
        // Act
        final signupResponse = SignupResponseEntity(
          userId: 'usr_67890',
          message: 'Registration successful',
        );

        // Assert
        expect(signupResponse.userId, equals('usr_67890'));
        expect(signupResponse.message, equals('Registration successful'));
      });

      test('should handle empty userId', () {
        // Act
        final signupResponse = SignupResponseEntity(
          userId: '',
          message: 'Empty user ID',
        );

        // Assert
        expect(signupResponse.userId, equals(''));
        expect(signupResponse.message, equals('Empty user ID'));
      });

      test('should handle empty message', () {
        // Act
        final signupResponse = SignupResponseEntity(
          userId: 'usr_12345',
          message: '',
        );

        // Assert
        expect(signupResponse.userId, equals('usr_12345'));
        expect(signupResponse.message, equals(''));
      });

      test('should handle null message', () {
        // Act
        final signupResponse = SignupResponseEntity(
          userId: 'usr_12345',
          message: null,
        );

        // Assert
        expect(signupResponse.userId, equals('usr_12345'));
        expect(signupResponse.message, isNull);
      });
    });

    group('Properties', () {
      test('should be immutable after creation', () {
        // Arrange
        final signupResponse = SignupResponseEntity(
          userId: 'usr_12345',
          message: 'Success message',
        );

        // Act & Assert - Properties should be final
        expect(signupResponse.userId, equals('usr_12345'));
        expect(signupResponse.message, equals('Success message'));

        // Verify property types
        expect(signupResponse.userId, isA<String>());
        expect(signupResponse.message, isA<String?>());
      });

      test('should handle various userId formats', () {
        // Arrange
        final userIdFormats = [
          'usr_12345',
          'user-uuid-1234-5678-9abc-def012345678',
          'farmer_001',
          'business_cooperative_456',
          'FARMER123',
          '1234567890',
          'user@domain.com', // Email-like ID
        ];

        for (final userId in userIdFormats) {
          // Act
          final signupResponse = SignupResponseEntity(userId: userId);

          // Assert
          expect(signupResponse.userId, equals(userId));
        }
      });

      test('should handle various message types', () {
        // Arrange
        final messages = [
          'Registration successful',
          'Welcome to Ethio-AgriBizBoost!',
          'Your account has been created',
          'Please verify your email address',
          'Thank you for joining our platform',
          'Registration completed. You can now login.',
          'Account created successfully. Welcome!',
        ];

        for (final message in messages) {
          // Act
          final signupResponse = SignupResponseEntity(
            userId: 'usr_12345',
            message: message,
          );

          // Assert
          expect(signupResponse.message, equals(message));
        }
      });

      test('should handle multilingual messages', () {
        // Arrange
        final multilingualMessages = [
          'Registration successful', // English
          'ምዝገባ ተጠናቅቋል', // Amharic
          'Enregistrement réussi', // French
          'Registrierung erfolgreich', // German
          '注册成功', // Chinese
          'تم التسجيل بنجاح', // Arabic
        ];

        for (final message in multilingualMessages) {
          // Act
          final signupResponse = SignupResponseEntity(
            userId: 'usr_international',
            message: message,
          );

          // Assert
          expect(signupResponse.message, equals(message));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very long userId', () {
        // Arrange
        final longUserId = 'usr_${'a' * 1000}';

        // Act
        final signupResponse = SignupResponseEntity(userId: longUserId);

        // Assert
        expect(signupResponse.userId, equals(longUserId));
      });

      test('should handle very long message', () {
        // Arrange
        final longMessage = 'Registration successful. ' * 100;

        // Act
        final signupResponse = SignupResponseEntity(
          userId: 'usr_12345',
          message: longMessage,
        );

        // Assert
        expect(signupResponse.message, equals(longMessage));
      });

      test('should handle special characters in userId', () {
        // Arrange
        const specialUserId = 'usr_123-456_789@domain.com';

        // Act
        final signupResponse = SignupResponseEntity(userId: specialUserId);

        // Assert
        expect(signupResponse.userId, equals(specialUserId));
      });

      test('should handle special characters in message', () {
        // Arrange
        const specialMessage =
            'Registration successful! @#\$%^&*()_+-={}[]|\\:";\'<>?,./';

        // Act
        final signupResponse = SignupResponseEntity(
          userId: 'usr_12345',
          message: specialMessage,
        );

        // Assert
        expect(signupResponse.message, equals(specialMessage));
      });

      test('should handle unicode in userId and message', () {
        // Arrange
        const unicodeUserId = 'farmer_中文_🌾_አማርኛ';
        const unicodeMessage =
            'Welcome 🎉 አንደኛ ሸማቻቸው 中文 to Ethio-AgriBizBoost!';

        // Act
        final signupResponse = SignupResponseEntity(
          userId: unicodeUserId,
          message: unicodeMessage,
        );

        // Assert
        expect(signupResponse.userId, equals(unicodeUserId));
        expect(signupResponse.message, equals(unicodeMessage));
      });
    });

    group('Business Logic Scenarios', () {
      test('should handle successful farmer registration response', () {
        // Act
        final farmerResponse = SignupResponseEntity(
          userId: 'farmer_ethiopian_001',
          message:
              'Welcome to Ethio-AgriBizBoost! Your farmer account has been created successfully.',
        );

        // Assert
        expect(farmerResponse.userId, contains('farmer'));
        expect(farmerResponse.userId, contains('ethiopian'));
        expect(farmerResponse.message, contains('Welcome'));
        expect(farmerResponse.message, contains('Ethio-AgriBizBoost'));
      });

      test('should handle cooperative registration response', () {
        // Act
        final cooperativeResponse = SignupResponseEntity(
          userId: 'coop_addis_coffee_001',
          message:
              'Your cooperative account has been created. Please verify your details.',
        );

        // Assert
        expect(cooperativeResponse.userId, contains('coop'));
        expect(cooperativeResponse.message, contains('cooperative'));
      });

      test('should handle business registration response', () {
        // Act
        final businessResponse = SignupResponseEntity(
          userId: 'biz_highland_agriculture_001',
          message:
              'Business registration completed. You can now access advanced features.',
        );

        // Assert
        expect(businessResponse.userId, contains('biz'));
        expect(businessResponse.message, contains('Business'));
        expect(businessResponse.message, contains('advanced features'));
      });
    });
  });

  group('SignupEntity Integration', () {
    test('should work together in typical registration flow', () {
      // Arrange - Create signup request
      final signupRequest = SignupRequestEntity(
        phoneNumber: '+251911234567',
        password: 'SecureFarmerPassword123!',
        name: 'Alemayehu Tekle',
        email: 'alemayehu.tekle@agri.et',
      );

      // Act - Simulate successful signup response
      final signupResponse = SignupResponseEntity(
        userId: 'farmer_alemayehu_001',
        message:
            'Welcome to Ethio-AgriBizBoost! Your account has been created successfully.',
      );

      // Assert - Verify both entities work correctly together
      expect(signupRequest.phoneNumber, equals('+251911234567'));
      expect(signupRequest.password, contains('SecureFarmer'));
      expect(signupRequest.name, equals('Alemayehu Tekle'));
      expect(signupRequest.email, contains('@agri.et'));

      expect(signupResponse.userId, contains('alemayehu'));
      expect(signupResponse.message, contains('Welcome'));
      expect(signupResponse.message, contains('Ethio-AgriBizBoost'));
    });

    test('should handle minimal registration flow', () {
      // Arrange - Create minimal signup request
      final signupRequest = SignupRequestEntity(
        phoneNumber: '+251911234567',
        password: 'SimplePass123',
      );

      // Act - Simulate minimal signup response
      final signupResponse = SignupResponseEntity(
        userId: 'usr_minimal_001',
      );

      // Assert
      expect(signupRequest.phoneNumber, isNotEmpty);
      expect(signupRequest.password, isNotEmpty);
      expect(signupRequest.name, isNull);
      expect(signupRequest.email, isNull);

      expect(signupResponse.userId, isNotEmpty);
      expect(signupResponse.message, isNull);
    });

    test('should handle registration with validation errors scenario', () {
      // Arrange - Create request with potentially problematic data
      final signupRequest = SignupRequestEntity(
        phoneNumber: 'invalid_phone',
        password: '123', // Weak password
        name: '', // Empty name
        email: 'invalid_email', // Invalid email format
      );

      // Act - Response might still be created but with error message
      final signupResponse = SignupResponseEntity(
        userId: 'temp_invalid_001',
        message: 'Registration failed: Please check your input data.',
      );

      // Assert - Data is preserved as-is (validation happens elsewhere)
      expect(signupRequest.phoneNumber, equals('invalid_phone'));
      expect(signupRequest.password, equals('123'));
      expect(signupRequest.name, equals(''));
      expect(signupRequest.email, equals('invalid_email'));

      expect(signupResponse.message, contains('failed'));
    });
  });
}
