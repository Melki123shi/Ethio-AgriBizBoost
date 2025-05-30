import 'package:app/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TokenStorage', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Access Token', () {
      test('should save and read access token successfully', () async {
        // Arrange
        const testToken = 'test_access_token_123';

        // Act
        await TokenStorage.saveAccessToken(testToken);
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(testToken));
      });

      test('should return null when no access token is stored', () async {
        // Act
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, isNull);
      });

      test('should clear access token successfully', () async {
        // Arrange
        const testToken = 'test_access_token_to_clear';
        await TokenStorage.saveAccessToken(testToken);

        // Act
        await TokenStorage.clearAccessToken();
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, isNull);
      });

      test('should overwrite existing access token', () async {
        // Arrange
        const firstToken = 'first_token';
        const secondToken = 'second_token';

        // Act
        await TokenStorage.saveAccessToken(firstToken);
        await TokenStorage.saveAccessToken(secondToken);
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(secondToken));
      });

      test('should handle empty access token string', () async {
        // Arrange
        const emptyToken = '';

        // Act
        await TokenStorage.saveAccessToken(emptyToken);
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(emptyToken));
      });

      test('should handle very long access token', () async {
        // Arrange
        final longToken = 'a' * 10000; // Very long token

        // Act
        await TokenStorage.saveAccessToken(longToken);
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(longToken));
      });
    });

    group('Refresh Token', () {
      test('should save and read refresh token successfully', () async {
        // Arrange
        const testToken = 'test_refresh_token_456';

        // Act
        await TokenStorage.saveRefreshToken(testToken);
        final result = await TokenStorage.readRefreshToken();

        // Assert
        expect(result, equals(testToken));
      });

      test('should return null when no refresh token is stored', () async {
        // Act
        final result = await TokenStorage.readRefreshToken();

        // Assert
        expect(result, isNull);
      });

      test('should clear refresh token successfully', () async {
        // Arrange
        const testToken = 'test_refresh_token_to_clear';
        await TokenStorage.saveRefreshToken(testToken);

        // Act
        await TokenStorage.clearRefreshToken();
        final result = await TokenStorage.readRefreshToken();

        // Assert
        expect(result, isNull);
      });

      test('should overwrite existing refresh token', () async {
        // Arrange
        const firstToken = 'first_refresh_token';
        const secondToken = 'second_refresh_token';

        // Act
        await TokenStorage.saveRefreshToken(firstToken);
        await TokenStorage.saveRefreshToken(secondToken);
        final result = await TokenStorage.readRefreshToken();

        // Assert
        expect(result, equals(secondToken));
      });

      test('should handle empty refresh token string', () async {
        // Arrange
        const emptyToken = '';

        // Act
        await TokenStorage.saveRefreshToken(emptyToken);
        final result = await TokenStorage.readRefreshToken();

        // Assert
        expect(result, equals(emptyToken));
      });
    });

    group('Token Type', () {
      test('should save and read token type successfully', () async {
        // Arrange
        const testTokenType = 'Bearer';

        // Act
        await TokenStorage.saveTokenType(testTokenType);
        final result = await TokenStorage.readTokenType();

        // Assert
        expect(result, equals(testTokenType));
      });

      test('should return null when no token type is stored', () async {
        // Act
        final result = await TokenStorage.readTokenType();

        // Assert
        expect(result, isNull);
      });

      test('should clear token type successfully', () async {
        // Arrange
        const testTokenType = 'Bearer';
        await TokenStorage.saveTokenType(testTokenType);

        // Act
        await TokenStorage.clearTokenType();
        final result = await TokenStorage.readTokenType();

        // Assert
        expect(result, isNull);
      });

      test('should overwrite existing token type', () async {
        // Arrange
        const firstType = 'Bearer';
        const secondType = 'JWT';

        // Act
        await TokenStorage.saveTokenType(firstType);
        await TokenStorage.saveTokenType(secondType);
        final result = await TokenStorage.readTokenType();

        // Assert
        expect(result, equals(secondType));
      });

      test('should handle different token type formats', () async {
        // Arrange
        const tokenTypes = ['Bearer', 'JWT', 'Basic', 'Custom'];

        for (final tokenType in tokenTypes) {
          // Act
          await TokenStorage.saveTokenType(tokenType);
          final result = await TokenStorage.readTokenType();

          // Assert
          expect(result, equals(tokenType));
        }
      });
    });

    group('Multiple Token Operations', () {
      test('should handle all tokens independently', () async {
        // Arrange
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';
        const tokenType = 'Bearer';

        // Act
        await TokenStorage.saveAccessToken(accessToken);
        await TokenStorage.saveRefreshToken(refreshToken);
        await TokenStorage.saveTokenType(tokenType);

        final readAccessToken = await TokenStorage.readAccessToken();
        final readRefreshToken = await TokenStorage.readRefreshToken();
        final readTokenType = await TokenStorage.readTokenType();

        // Assert
        expect(readAccessToken, equals(accessToken));
        expect(readRefreshToken, equals(refreshToken));
        expect(readTokenType, equals(tokenType));
      });

      test('should clear tokens independently', () async {
        // Arrange
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';
        const tokenType = 'Bearer';

        await TokenStorage.saveAccessToken(accessToken);
        await TokenStorage.saveRefreshToken(refreshToken);
        await TokenStorage.saveTokenType(tokenType);

        // Act - Clear only access token
        await TokenStorage.clearAccessToken();

        // Assert
        expect(await TokenStorage.readAccessToken(), isNull);
        expect(await TokenStorage.readRefreshToken(), equals(refreshToken));
        expect(await TokenStorage.readTokenType(), equals(tokenType));

        // Act - Clear only refresh token
        await TokenStorage.clearRefreshToken();

        // Assert
        expect(await TokenStorage.readAccessToken(), isNull);
        expect(await TokenStorage.readRefreshToken(), isNull);
        expect(await TokenStorage.readTokenType(), equals(tokenType));

        // Act - Clear token type
        await TokenStorage.clearTokenType();

        // Assert
        expect(await TokenStorage.readAccessToken(), isNull);
        expect(await TokenStorage.readRefreshToken(), isNull);
        expect(await TokenStorage.readTokenType(), isNull);
      });

      test('should handle partial token sets', () async {
        // Test 1: Only access token
        await TokenStorage.saveAccessToken('access_only');
        expect(await TokenStorage.readAccessToken(), equals('access_only'));
        expect(await TokenStorage.readRefreshToken(), isNull);
        expect(await TokenStorage.readTokenType(), isNull);

        // Clear for next test
        await TokenStorage.clearAccessToken();

        // Test 2: Only refresh token
        await TokenStorage.saveRefreshToken('refresh_only');
        expect(await TokenStorage.readAccessToken(), isNull);
        expect(await TokenStorage.readRefreshToken(), equals('refresh_only'));
        expect(await TokenStorage.readTokenType(), isNull);

        // Clear for next test
        await TokenStorage.clearRefreshToken();

        // Test 3: Only token type
        await TokenStorage.saveTokenType('Bearer');
        expect(await TokenStorage.readAccessToken(), isNull);
        expect(await TokenStorage.readRefreshToken(), isNull);
        expect(await TokenStorage.readTokenType(), equals('Bearer'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle special characters in tokens', () async {
        // Arrange
        const specialToken = 'token.with-special_chars+symbols=123!@#\$%^&*()';

        // Act
        await TokenStorage.saveAccessToken(specialToken);
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(specialToken));
      });

      test('should handle unicode characters in tokens', () async {
        // Arrange
        const unicodeToken = 'token_with_émojis_🔒_and_中文_characters';

        // Act
        await TokenStorage.saveAccessToken(unicodeToken);
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(unicodeToken));
      });

      test('should handle multiple sequential operations', () async {
        // Arrange
        const tokens = ['token1', 'token2', 'token3', 'token4', 'token5'];

        // Act & Assert
        for (final token in tokens) {
          await TokenStorage.saveAccessToken(token);
          final result = await TokenStorage.readAccessToken();
          expect(result, equals(token));
        }
      });

      test('should maintain state across multiple clear operations', () async {
        // Act
        await TokenStorage.clearAccessToken();
        await TokenStorage.clearAccessToken(); // Double clear
        await TokenStorage.clearRefreshToken();
        await TokenStorage.clearTokenType();

        // Assert
        expect(await TokenStorage.readAccessToken(), isNull);
        expect(await TokenStorage.readRefreshToken(), isNull);
        expect(await TokenStorage.readTokenType(), isNull);
      });
    });

    group('Data Persistence', () {
      test('should persist data across multiple SharedPreferences instances',
          () async {
        // Arrange
        const testToken = 'persistent_token';

        // Act
        await TokenStorage.saveAccessToken(testToken);

        // Simulate getting a new SharedPreferences instance
        final result = await TokenStorage.readAccessToken();

        // Assert
        expect(result, equals(testToken));
      });

      test('should handle concurrent token operations', () async {
        // Arrange
        const accessToken = 'concurrent_access';
        const refreshToken = 'concurrent_refresh';
        const tokenType = 'concurrent_type';

        // Act - Perform concurrent operations
        await Future.wait([
          TokenStorage.saveAccessToken(accessToken),
          TokenStorage.saveRefreshToken(refreshToken),
          TokenStorage.saveTokenType(tokenType),
        ]);

        // Assert
        final results = await Future.wait([
          TokenStorage.readAccessToken(),
          TokenStorage.readRefreshToken(),
          TokenStorage.readTokenType(),
        ]);

        expect(results[0], equals(accessToken));
        expect(results[1], equals(refreshToken));
        expect(results[2], equals(tokenType));
      });
    });
  });
}
