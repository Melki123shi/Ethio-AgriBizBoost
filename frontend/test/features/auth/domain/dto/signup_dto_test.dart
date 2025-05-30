import 'package:app/domain/dto/signup_dto.dart';
import 'package:app/domain/entity/signup_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignupRequestDTO', () {
    group('Constructor', () {
      test('should create SignupRequestDTO with required fields', () {
        // Act
        final dto = SignupRequestDTO(
          phoneNumber: '+251911234567',
          password: 'securePassword123',
          email: 'test@example.com',
        );

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('securePassword123'));
        expect(dto.email, equals('test@example.com'));
        expect(dto.name, isNull);
      });

      test('should create SignupRequestDTO with all fields', () {
        // Act
        final dto = SignupRequestDTO(
          phoneNumber: '+251922123456',
          password: 'farmerPass@2023',
          name: 'Abebe Kebede',
          email: 'abebe@farmer.et',
        );

        // Assert
        expect(dto.phoneNumber, equals('+251922123456'));
        expect(dto.password, equals('farmerPass@2023'));
        expect(dto.name, equals('Abebe Kebede'));
        expect(dto.email, equals('abebe@farmer.et'));
      });

      test('should create SignupRequestDTO with Ethiopian names', () {
        // Act
        final dto = SignupRequestDTO(
          phoneNumber: '+251933987654',
          password: 'strongPassword',
          name: 'ወይዘሮ ፋጦማ አህመድ',
          email: 'fatuma@coop.et',
        );

        // Assert
        expect(dto.phoneNumber, equals('+251933987654'));
        expect(dto.name, equals('ወይዘሮ ፋጦማ አህመድ'));
        expect(dto.email, equals('fatuma@coop.et'));
      });

      test('should create SignupRequestDTO with null name', () {
        // Act
        final dto = SignupRequestDTO(
          phoneNumber: '+251944556677',
          password: 'testPassword',
          name: null,
          email: 'anonymous@test.com',
        );

        // Assert
        expect(dto.phoneNumber, equals('+251944556677'));
        expect(dto.name, isNull);
        expect(dto.email, equals('anonymous@test.com'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly with all fields', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251911234567',
          password: 'testPassword123',
          name: 'John Doe',
          email: 'john@example.com',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'phone_number': '+251911234567',
          'password': 'testPassword123',
          'name': 'John Doe',
          'email': 'john@example.com',
        });
      });

      test('should serialize to JSON with null name', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251922334455',
          password: 'password123',
          name: null,
          email: 'test@domain.com',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'phone_number': '+251922334455',
          'password': 'password123',
          'name': null,
          'email': 'test@domain.com',
        });
      });

      test('should serialize Ethiopian farmer data correctly', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251933445566',
          password: 'FarmerTeff2023!',
          name: 'አቶ ታደሰ ገብሩ',
          email: 'tadesse.gebru@farmer.et',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], equals('+251933445566'));
        expect(json['name'], equals('አቶ ታደሰ ገብሩ'));
        expect(json['email'], equals('tadesse.gebru@farmer.et'));
        expect(json['password'], equals('FarmerTeff2023!'));
      });

      test('should serialize with special characters in password', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251944123789',
          password: 'Complex@Pass#2023!\$%',
          name: 'Test User',
          email: 'test@special.com',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['password'], equals('Complex@Pass#2023!\$%'));
      });

      test('should serialize empty strings correctly', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '',
          password: '',
          name: '',
          email: '',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], equals(''));
        expect(json['password'], equals(''));
        expect(json['name'], equals(''));
        expect(json['email'], equals(''));
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON correctly with all fields', () {
        // Arrange
        final json = {
          'phone_number': '+251911234567',
          'password': 'testPassword123',
          'name': 'John Doe',
          'email': 'john@example.com',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('testPassword123'));
        expect(dto.name, equals('John Doe'));
        expect(dto.email, equals('john@example.com'));
      });

      test('should deserialize with missing optional fields', () {
        // Arrange
        final json = {
          'phone_number': '+251922334455',
          'password': 'password123',
          'email': 'test@domain.com',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251922334455'));
        expect(dto.password, equals('password123'));
        expect(dto.name, equals(''));
        expect(dto.email, equals('test@domain.com'));
      });

      test('should deserialize with missing required fields using defaults',
          () {
        // Arrange
        final json = {
          'name': 'Only Name',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals(''));
        expect(dto.password, equals(''));
        expect(dto.name, equals('Only Name'));
        expect(dto.email, equals(''));
      });

      test('should deserialize with null values using defaults', () {
        // Arrange
        final json = {
          'phone_number': null,
          'password': null,
          'name': null,
          'email': null,
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals(''));
        expect(dto.password, equals(''));
        expect(dto.name, equals(''));
        expect(dto.email, equals(''));
      });

      test('should deserialize with extra fields', () {
        // Arrange
        final json = {
          'phone_number': '+251933445566',
          'password': 'password123',
          'name': 'Test User',
          'email': 'test@example.com',
          'extra_field': 'ignored',
          'another_field': 42,
          'timestamp': '2023-01-01',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251933445566'));
        expect(dto.password, equals('password123'));
        expect(dto.name, equals('Test User'));
        expect(dto.email, equals('test@example.com'));
      });

      test('should deserialize Ethiopian agricultural user data', () {
        // Arrange
        final json = {
          'phone_number': '+251944556677',
          'password': 'CoopPassword2023',
          'name': 'ወይዘሮ አልማዝ ወርቁ',
          'email': 'almaz.worku@sidama.coop.et',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251944556677'));
        expect(dto.name, equals('ወይዘሮ አልማዝ ወርቁ'));
        expect(dto.email, equals('almaz.worku@sidama.coop.et'));
      });
    });

    group('Entity Conversion', () {
      test('should convert from entity correctly', () {
        // Arrange
        final entity = SignupRequestEntity(
          phoneNumber: '+251911234567',
          password: 'entityPassword',
          name: 'Entity User',
          email: 'entity@test.com',
        );

        // Act
        final dto = SignupRequestDTO.fromEntity(entity);

        // Assert
        expect(dto.phoneNumber, equals('+251911234567'));
        expect(dto.password, equals('entityPassword'));
        expect(dto.name, equals('Entity User'));
        expect(dto.email, equals('entity@test.com'));
      });

      test('should convert to entity correctly', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251933123456',
          password: 'dtoPassword',
          name: 'DTO User',
          email: 'dto@test.com',
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.phoneNumber, equals('+251933123456'));
        expect(entity.password, equals('dtoPassword'));
        expect(entity.name, equals('DTO User'));
        expect(entity.email, equals('dto@test.com'));
      });

      test('should maintain data integrity during round-trip conversion', () {
        // Arrange
        final originalEntity = SignupRequestEntity(
          phoneNumber: '+251922998877',
          password: 'roundTripPassword!@#',
          name: 'Round Trip User',
          email: 'roundtrip@test.com',
        );

        // Act
        final dto = SignupRequestDTO.fromEntity(originalEntity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.phoneNumber, equals(originalEntity.phoneNumber));
        expect(convertedEntity.password, equals(originalEntity.password));
        expect(convertedEntity.name, equals(originalEntity.name));
        expect(convertedEntity.email, equals(originalEntity.email));
      });

      test('should handle null values in entity conversion', () {
        // Arrange
        final entity = SignupRequestEntity(
          phoneNumber: '',
          password: '',
          name: null,
          email: '',
        );

        // Act
        final dto = SignupRequestDTO.fromEntity(entity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.phoneNumber, equals(''));
        expect(convertedEntity.password, equals(''));
        expect(convertedEntity.name, isNull);
        expect(convertedEntity.email, equals(''));
      });

      test('should convert Ethiopian farmer entity correctly', () {
        // Arrange
        final entity = SignupRequestEntity(
          phoneNumber: '+251944123789',
          password: 'FarmerEntityPass',
          name: 'አቶ በላይ ተስፋዬ',
          email: 'belay.tesfaye@oromia.farmer.et',
        );

        // Act
        final dto = SignupRequestDTO.fromEntity(entity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.name, equals('አቶ በላይ ተስፋዬ'));
        expect(convertedEntity.email, equals('belay.tesfaye@oromia.farmer.et'));
        expect(convertedEntity.phoneNumber, equals('+251944123789'));
      });
    });

    group('Ethiopian Agriculture Context', () {
      test('should handle individual farmer registration', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251912345678',
          password: 'TeffFarmer2023!',
          name: 'አቶ ሀብታሙ መኮንን',
          email: 'habtamu.mekonnen@teff.farmer.et',
        );

        // Act
        final json = dto.toJson();
        final entity = dto.toEntity();

        // Assert
        expect(json['phone_number'], equals('+251912345678'));
        expect(entity.name, equals('አቶ ሀብታሙ መኮንን'));
        expect(entity.email, contains('teff.farmer.et'));
      });

      test('should handle cooperative member registration', () {
        // Arrange
        final json = {
          'phone_number': '+251933567890',
          'password': 'CoopMember@Sidama2023',
          'name': 'ወይዘሮ ሰላሜ ሀይሌ',
          'email': 'selame.haile@sidama.coffee.coop.et',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);

        // Assert
        expect(dto.phoneNumber, equals('+251933567890'));
        expect(dto.name, equals('ወይዘሮ ሰላሜ ሀይሌ'));
        expect(dto.email, contains('coffee.coop.et'));
        expect(dto.password, contains('Sidama'));
      });

      test('should handle agricultural advisor registration', () {
        // Arrange
        final entity = SignupRequestEntity(
          phoneNumber: '+251944987654',
          password: 'AdvisorAmhara123',
          name: 'Dr. Mulugeta Assefa',
          email: 'mulugeta.assefa@amhara.advisor.gov.et',
        );

        // Act
        final dto = SignupRequestDTO.fromEntity(entity);
        final json = dto.toJson();

        // Assert
        expect(json['phone_number'], equals('+251944987654'));
        expect(json['name'], equals('Dr. Mulugeta Assefa'));
        expect(json['email'], contains('advisor.gov.et'));
      });

      test('should handle agro-dealer registration', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251955123456',
          password: 'AgroDealer@AddisAbaba',
          name: 'አቶ ይልማ ገብረመድህን',
          email: 'yilma.gebremedhin@agro.dealer.et',
        );

        // Act
        final entity = dto.toEntity();
        final json = dto.toJson();

        // Assert
        expect(entity.phoneNumber, equals('+251955123456'));
        expect(json['email'], contains('agro.dealer.et'));
        expect(json['name'], equals('አቶ ይልማ ገብረመድህን'));
      });

      test('should handle women farmer group leader registration', () {
        // Arrange
        final json = {
          'phone_number': '+251911987654',
          'password': 'WomenGroup@Leader2023',
          'name': 'ወይዘሮ ማርታ ተክሌ',
          'email': 'marta.tekle@women.farmers.tigray.et',
        };

        // Act
        final dto = SignupRequestDTO.fromJson(json);
        final entity = dto.toEntity();

        // Assert
        expect(dto.phoneNumber, equals('+251911987654'));
        expect(entity.name, equals('ወይዘሮ ማርታ ተክሌ'));
        expect(entity.email, contains('women.farmers'));
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle very long Ethiopian names', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251966123456',
          password: 'longNamePassword',
          name: 'አቶ አብርሃም ወልደማርያም ተስፋምካኤል ገብረሥላሴ',
          email: 'long.name@example.com',
        );

        // Act
        final json = dto.toJson();
        final entity = dto.toEntity();

        // Assert
        expect(entity.name, equals('አቶ አብርሃም ወልደማርያም ተስፋምካኤል ገብረሥላሴ'));
        expect(json['name'], equals(entity.name));
      });

      test('should handle multiple Ethiopian phone number formats', () {
        final phoneFormats = [
          '+251911234567', // International format
          '0911234567', // Local format with leading zero
          '911234567', // Local format without leading zero
          '+251-91-123-4567', // International with dashes
        ];

        for (final phone in phoneFormats) {
          // Act
          final dto = SignupRequestDTO(
            phoneNumber: phone,
            password: 'testPassword',
            email: 'test@example.com',
          );

          // Assert
          expect(dto.phoneNumber, equals(phone));
        }
      });

      test('should handle mixed language emails', () {
        // Arrange
        final dto = SignupRequestDTO(
          phoneNumber: '+251977123456',
          password: 'mixedPassword',
          name: 'Hybrid User',
          email: 'user@አዲስ.ዐለም.et', // Mixed script email
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['email'], equals('user@አዲስ.ዐለም.et'));
      });
    });
  });

  group('SignupResponseDTO', () {
    group('Constructor', () {
      test('should create SignupResponseDTO with required fields', () {
        // Act
        final dto = SignupResponseDTO(
          userId: 'user_123456',
        );

        // Assert
        expect(dto.userId, equals('user_123456'));
        expect(dto.message, isNull);
      });

      test('should create SignupResponseDTO with all fields', () {
        // Act
        final dto = SignupResponseDTO(
          userId: 'farmer_789012',
          message: 'Registration successful! Welcome to Ethio-AgriBizBoost.',
        );

        // Assert
        expect(dto.userId, equals('farmer_789012'));
        expect(dto.message,
            equals('Registration successful! Welcome to Ethio-AgriBizBoost.'));
      });

      test('should create SignupResponseDTO with Ethiopian message', () {
        // Act
        final dto = SignupResponseDTO(
          userId: 'user_345678',
          message: 'ምዝገባዎ በተሳካ ሁኔታ ተጠናቅቋል! እንኳን ደህና መጡ።',
        );

        // Assert
        expect(dto.userId, equals('user_345678'));
        expect(dto.message, equals('ምዝገባዎ በተሳካ ሁኔታ ተጠናቅቋል! እንኳን ደህና መጡ።'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly with all fields', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'user_123',
          message: 'Welcome to the platform!',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'user_id': 'user_123',
          'message': 'Welcome to the platform!',
        });
      });

      test('should serialize to JSON without optional message', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'user_456',
          message: null,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'user_id': 'user_456',
        });
        expect(json.containsKey('message'), isFalse);
      });

      test('should serialize Ethiopian success message', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'farmer_et_001',
          message: 'በኢትዮ-አግሪቢዝቡስት ውስጥ እንኳን ደህና መጡ! ይህ የእርስዎ የግብርና ንግድ ጅምር ነው።',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['user_id'], equals('farmer_et_001'));
        expect(json['message'], contains('ኢትዮ-አግሪቢዝቡስት'));
      });

      test('should serialize empty message correctly', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'user_empty',
          message: '',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json, {
          'user_id': 'user_empty',
          'message': '',
        });
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'user_id': 'user_123',
          'message': 'Registration successful!',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals('user_123'));
        expect(dto.message, equals('Registration successful!'));
      });

      test('should deserialize with missing message field', () {
        // Arrange
        final json = {
          'user_id': 'user_456',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals('user_456'));
        expect(dto.message, isNull);
      });

      test('should deserialize with missing user_id using default', () {
        // Arrange
        final json = {
          'message': 'Only message present',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals(''));
        expect(dto.message, equals('Only message present'));
      });

      test('should deserialize with null values', () {
        // Arrange
        final json = {
          'user_id': null,
          'message': null,
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals(''));
        expect(dto.message, isNull);
      });

      test('should deserialize Ethiopian API response', () {
        // Arrange
        final json = {
          'user_id': 'farmer_et_12345',
          'message': 'የገበሬ ምዝገባ በተሳካ ሁኔታ ተጠናቅቋል። በቅርቡ የምርጃ ምክሮች ይደርስዎታል።',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals('farmer_et_12345'));
        expect(dto.message, contains('ምዝገባ'));
        expect(dto.message, contains('ተጠናቅቋል'));
      });

      test('should deserialize with extra fields', () {
        // Arrange
        final json = {
          'user_id': 'user_extra',
          'message': 'Success message',
          'timestamp': '2023-01-01T00:00:00Z',
          'status_code': 201,
          'extra_field': 'ignored',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals('user_extra'));
        expect(dto.message, equals('Success message'));
      });
    });

    group('Entity Conversion', () {
      test('should convert from entity correctly', () {
        // Arrange
        final entity = SignupResponseEntity(
          userId: 'entity_user_123',
          message: 'Entity message',
        );

        // Act
        final dto = SignupResponseDTO.fromEntity(entity);

        // Assert
        expect(dto.userId, equals('entity_user_123'));
        expect(dto.message, equals('Entity message'));
      });

      test('should convert to entity correctly', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'dto_user_456',
          message: 'DTO message',
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.userId, equals('dto_user_456'));
        expect(entity.message, equals('DTO message'));
      });

      test('should maintain data integrity during round-trip conversion', () {
        // Arrange
        final originalEntity = SignupResponseEntity(
          userId: 'round_trip_user',
          message: 'Round trip message with special chars: !@#\$%',
        );

        // Act
        final dto = SignupResponseDTO.fromEntity(originalEntity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.userId, equals(originalEntity.userId));
        expect(convertedEntity.message, equals(originalEntity.message));
      });

      test('should handle null message in entity conversion', () {
        // Arrange
        final entity = SignupResponseEntity(
          userId: 'user_null_message',
          message: null,
        );

        // Act
        final dto = SignupResponseDTO.fromEntity(entity);
        final convertedEntity = dto.toEntity();

        // Assert
        expect(convertedEntity.userId, equals('user_null_message'));
        expect(convertedEntity.message, isNull);
      });
    });

    group('Ethiopian Agriculture Context', () {
      test('should handle farmer registration success response', () {
        // Arrange
        final json = {
          'user_id': 'farmer_teff_001',
          'message':
              'እንኳን ደህና መጡ! የጤፍ አምራች ተብለው ተመዝግበዋል። የአዲሱ የእርስዎ የግብርና ጉዞ እዚህ ይጀምራል!',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);
        final entity = dto.toEntity();

        // Assert
        expect(entity.userId, equals('farmer_teff_001'));
        expect(entity.message, contains('ጤፍ አምራች'));
        expect(entity.message, contains('እንኳን ደህና መጡ'));
      });

      test('should handle cooperative registration success', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'coop_sidama_coffee_001',
          message:
              'Sidama Coffee Cooperative registration completed successfully! You can now access premium coffee market features.',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['user_id'], equals('coop_sidama_coffee_001'));
        expect(json['message'], contains('Sidama Coffee'));
        expect(json['message'], contains('Cooperative'));
      });

      test('should handle multilingual success messages', () {
        // Arrange
        final entity = SignupResponseEntity(
          userId: 'multilingual_user_001',
          message:
              'Welcome! እንኳን ደህና መጡ! Baga nagaan dhuftan! Registration successful.',
        );

        // Act
        final dto = SignupResponseDTO.fromEntity(entity);
        final json = dto.toJson();

        // Assert
        expect(json['user_id'], equals('multilingual_user_001'));
        expect(json['message'], contains('Welcome'));
        expect(json['message'], contains('እንኳን ደህና መጡ'));
        expect(json['message'], contains('Baga nagaan dhuftan'));
      });

      test('should handle agricultural advisor registration', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: 'advisor_amhara_001',
          message:
              'Agricultural Advisor registration successful. You now have access to farmer consultation and crop management tools.',
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.userId, equals('advisor_amhara_001'));
        expect(entity.message, contains('Agricultural Advisor'));
        expect(entity.message, contains('consultation'));
      });

      test('should handle agro-dealer business registration', () {
        // Arrange
        final json = {
          'user_id': 'agro_dealer_addis_001',
          'message':
              'Agro-dealer business registration completed! Start connecting with farmers and managing your agricultural input supply chain.',
        };

        // Act
        final dto = SignupResponseDTO.fromJson(json);

        // Assert
        expect(dto.userId, equals('agro_dealer_addis_001'));
        expect(dto.message, contains('Agro-dealer'));
        expect(dto.message, contains('supply chain'));
      });
    });

    group('Error and Edge Cases', () {
      test('should handle empty user ID', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: '',
          message: 'Empty user ID case',
        );

        // Act
        final json = dto.toJson();
        final entity = dto.toEntity();

        // Assert
        expect(entity.userId, equals(''));
        expect(json['user_id'], equals(''));
      });

      test('should handle very long success messages', () {
        // Arrange
        final longMessage =
            'This is a very long success message that might be returned from the API when providing detailed information about the registration process and next steps for the agricultural business user registration in the Ethio-AgriBizBoost platform.';
        final dto = SignupResponseDTO(
          userId: 'user_long_message',
          message: longMessage,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['message'], equals(longMessage));
        expect(json['message'].length, greaterThan(200));
      });

      test('should handle UUID-style user IDs', () {
        // Arrange
        final dto = SignupResponseDTO(
          userId: '550e8400-e29b-41d4-a716-446655440000',
          message: 'UUID format user ID',
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.userId, equals('550e8400-e29b-41d4-a716-446655440000'));
        expect(entity.userId, contains('-'));
      });
    });
  });
}
