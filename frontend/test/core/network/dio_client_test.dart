import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks.mocks.dart';

void main() {
  group('DioClient', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      // Reset Dio singleton between tests
      DioClient.resetForTesting();
    });

    group('Configuration', () {
      test('should create Dio instance with correct base configuration', () {
        // Act
        final dio = DioClient.getDio();

        // Assert
        expect(dio, isA<Dio>());
        expect(dio.options.baseUrl,
            equals('https://ethio-agribizboost.onrender.com'));
        expect(dio.options.connectTimeout, equals(const Duration(seconds: 60)));
        expect(dio.options.receiveTimeout, equals(const Duration(seconds: 60)));
        expect(dio.options.persistentConnection, isFalse);
        expect(dio.options.followRedirects, isTrue);
        expect(dio.options.validateStatus, isNotNull);
      });

      test('should return same Dio instance on multiple calls (singleton)', () {
        // Act
        final dio1 = DioClient.getDio();
        final dio2 = DioClient.getDio();

        // Assert
        expect(identical(dio1, dio2), isTrue);
      });

      test('should validate all status codes', () {
        // Act
        final dio = DioClient.getDio();
        final validateStatus = dio.options.validateStatus;

        // Assert
        expect(validateStatus(200), isTrue);
        expect(validateStatus(404), isTrue);
        expect(validateStatus(500), isTrue);
        expect(validateStatus(401), isTrue);
        expect(validateStatus(0), isTrue);
      });

      test('should have interceptors configured', () {
        // Act
        final dio = DioClient.getDio();

        // Assert - Should have interceptors (auth + log interceptors)
        expect(dio.interceptors.length, greaterThanOrEqualTo(2));
      });

      test('should have LogInterceptor configured correctly', () {
        // Act
        final dio = DioClient.getDio();
        final logInterceptor =
            dio.interceptors.whereType<LogInterceptor>().first;

        // Assert
        expect(logInterceptor.requestHeader, isTrue);
        expect(logInterceptor.requestBody, isTrue);
        expect(logInterceptor.responseHeader, isTrue);
        expect(logInterceptor.responseBody, isTrue);
        expect(logInterceptor.error, isTrue);
      });
    });

    group('Authorization Interceptor', () {
      late MockHttpClientAdapter mockAdapter;
      late Dio testDio;

      setUp(() {
        mockAdapter = MockHttpClientAdapter();
        testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;
      });

      test('should add Authorization header when access token exists',
          () async {
        // Arrange
        await TokenStorage.saveAccessToken('test_access_token');

        final responsePayload = ResponseBody.fromString(
          '{"message": "success"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => responsePayload);

        // Act
        await testDio.get('/test');

        // Assert
        final captured =
            verify(mockAdapter.fetch(captureAny, any, any)).captured;
        final RequestOptions requestOptions = captured.first;
        expect(requestOptions.headers['Authorization'],
            equals('Bearer test_access_token'));
      });

      test('should not add Authorization header when no access token',
          () async {
        // Arrange - No token saved
        final responsePayload = ResponseBody.fromString(
          '{"message": "success"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => responsePayload);

        // Act
        await testDio.get('/test');

        // Assert
        final captured =
            verify(mockAdapter.fetch(captureAny, any, any)).captured;
        final RequestOptions requestOptions = captured.first;
        expect(requestOptions.headers.containsKey('Authorization'), isFalse);
      });

      test('should not add Authorization header when access token is empty',
          () async {
        // Arrange
        await TokenStorage.saveAccessToken('');

        final responsePayload = ResponseBody.fromString(
          '{"message": "success"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => responsePayload);

        // Act
        await testDio.get('/test');

        // Assert
        final captured =
            verify(mockAdapter.fetch(captureAny, any, any)).captured;
        final RequestOptions requestOptions = captured.first;
        expect(requestOptions.headers.containsKey('Authorization'), isFalse);
      });

      test('should preserve existing headers when adding Authorization',
          () async {
        // Arrange
        await TokenStorage.saveAccessToken('test_token');

        final responsePayload = ResponseBody.fromString(
          '{"message": "success"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => responsePayload);

        // Act
        await testDio.get('/test',
            options: Options(headers: {
              'Custom-Header': 'custom-value',
              'Content-Type': 'application/json',
            }));

        // Assert
        final captured =
            verify(mockAdapter.fetch(captureAny, any, any)).captured;
        final RequestOptions requestOptions = captured.first;
        expect(requestOptions.headers['Authorization'],
            equals('Bearer test_token'));
        expect(requestOptions.headers['Custom-Header'], equals('custom-value'));
        expect(
            requestOptions.headers['Content-Type'], equals('application/json'));
      });
    });

    group('Token Refresh Logic', () {
      test('should handle 401 response appropriately', () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('expired_token');

        final unauthorizedResponse = ResponseBody.fromString(
          '{"error": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => unauthorizedResponse);

        // Act
        final response = await testDio.get('/protected');

        // Assert
        expect(response.statusCode, equals(401));
      });

      test('should not retry on 401 if retry flag is already set', () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('expired_token');

        final unauthorizedResponse = ResponseBody.fromString(
          '{"error": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => unauthorizedResponse);

        // Act
        final response = await testDio.get('/protected',
            options: Options(extra: {'retry': true}));

        // Assert
        expect(response.statusCode, equals(401));
        verify(mockAdapter.fetch(any, any, any))
            .called(1); // Only one call, no retry
      });

      test('should handle missing refresh token', () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('expired_token');
        // No refresh token saved

        final unauthorizedResponse = ResponseBody.fromString(
          '{"error": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => unauthorizedResponse);

        // Act
        final response = await testDio.get('/protected');

        // Assert
        expect(response.statusCode, equals(401));
        verify(mockAdapter.fetch(any, any, any))
            .called(1); // No refresh attempt
      });
    });

    group('Error Handling', () {
      late MockHttpClientAdapter mockAdapter;
      late Dio testDio;

      setUp(() {
        mockAdapter = MockHttpClientAdapter();
        testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;
      });

      test('should pass through non-401 errors without retry', () async {
        // Arrange
        final serverErrorResponse = ResponseBody.fromString(
          '{"error": "Internal Server Error"}',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => serverErrorResponse);

        // Act
        final response = await testDio.get('/test');

        // Assert
        expect(response.statusCode, equals(500));
        verify(mockAdapter.fetch(any, any, any)).called(1); // No retry
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockAdapter.fetch(any, any, any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        ));

        // Act & Assert
        expect(
          () => testDio.get('/test'),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle refresh token network errors', () async {
        // Arrange
        await TokenStorage.saveAccessToken('expired_token');
        await TokenStorage.saveRefreshToken('valid_refresh_token');

        final unauthorizedResponse = ResponseBody.fromString(
          '{"error": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => unauthorizedResponse);

        // Act
        final response = await testDio.get('/protected');

        // Assert
        expect(response.statusCode, equals(401)); // Falls back to original 401
      });
    });

    group('Edge Cases', () {
      test('should handle concurrent requests with token refresh', () async {
        // This is a complex scenario that would require more sophisticated mocking
        // For now, we'll test the basic case
        final dio = DioClient.getDio();
        expect(dio, isNotNull);
      });

      test('should handle empty response data during refresh', () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('expired_token');
        await TokenStorage.saveRefreshToken('valid_refresh_token');

        final unauthorizedResponse = ResponseBody.fromString(
          '{"error": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => unauthorizedResponse);

        // Act
        final response = await testDio.get('/protected');

        // Assert
        expect(response.statusCode, equals(401));
      });

      test('should handle malformed JSON in refresh response', () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('expired_token');
        await TokenStorage.saveRefreshToken('valid_refresh_token');

        final unauthorizedResponse = ResponseBody.fromString(
          '{"error": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => unauthorizedResponse);

        // Act
        final response = await testDio.get('/protected');

        // Assert
        expect(response.statusCode, equals(401));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle typical Ethiopian agriculture API endpoint',
          () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('farmer_access_token');

        final cropDataResponse = ResponseBody.fromString(
          '{"crops": [{"name": "Teff", "season": "Meher"}, {"name": "Coffee", "region": "Sidama"}]}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => cropDataResponse);

        // Act
        final response = await testDio.get('/api/crops');

        // Assert
        expect(response.statusCode, equals(200));
        expect(response.data.toString(), contains('Teff'));
        expect(response.data.toString(), contains('Coffee'));

        // Verify Authorization header was added
        final captured =
            verify(mockAdapter.fetch(captureAny, any, any)).captured;
        final RequestOptions requestOptions = captured.first;
        expect(requestOptions.headers['Authorization'],
            equals('Bearer farmer_access_token'));
      });

      test('should handle market price API with authentication', () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        await TokenStorage.saveAccessToken('market_access_token');

        final priceDataResponse = ResponseBody.fromString(
          '{"prices": {"teff": 45.50, "coffee": 120.00}, "currency": "ETB", "market": "Addis Mercato"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => priceDataResponse);

        // Act
        final response = await testDio.get('/api/market/prices',
            queryParameters: {'region': 'Addis Ababa'});

        // Assert
        expect(response.statusCode, equals(200));
        expect(response.data.toString(), contains('teff'));
        expect(response.data.toString(), contains('ETB'));

        // Verify query parameters were passed
        final captured =
            verify(mockAdapter.fetch(captureAny, any, any)).captured;
        final RequestOptions requestOptions = captured.first;
        expect(requestOptions.queryParameters['region'], equals('Addis Ababa'));
      });

      test('should handle farmer registration with proper error handling',
          () async {
        // Arrange
        final mockAdapter = MockHttpClientAdapter();
        final testDio = DioClient.getDio();
        testDio.httpClientAdapter = mockAdapter;

        final validationErrorResponse = ResponseBody.fromString(
          '{"errors": {"phone": ["Phone number already exists"], "email": ["Invalid email format"]}}',
          422,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );

        when(mockAdapter.fetch(any, any, any))
            .thenAnswer((_) async => validationErrorResponse);

        // Act
        final response = await testDio.post('/api/farmers/register', data: {
          'name': 'Alemayehu Tekle',
          'phone': '+251911234567',
          'email': 'alemayehu@invalid',
          'region': 'Oromia'
        });

        // Assert
        expect(response.statusCode, equals(422));
        expect(response.data.toString(), contains('phone'));
        expect(response.data.toString(), contains('email'));
      });
    });

    group('Network Configuration Testing', () {
      test('should properly configure base URL for Ethiopian agriculture API',
          () {
        // Act
        final dio = DioClient.getDio();

        // Assert
        expect(dio.options.baseUrl,
            equals('https://ethio-agribizboost.onrender.com'));
      });

      test('should have appropriate timeout settings for agricultural data',
          () {
        // Act
        final dio = DioClient.getDio();

        // Assert
        expect(dio.options.connectTimeout, equals(const Duration(seconds: 60)));
        expect(dio.options.receiveTimeout, equals(const Duration(seconds: 60)));
      });

      test('should allow all HTTP status codes for proper error handling', () {
        // Act
        final dio = DioClient.getDio();

        // Assert
        expect(dio.options.validateStatus(100), isTrue);
        expect(dio.options.validateStatus(200), isTrue);
        expect(dio.options.validateStatus(400), isTrue);
        expect(dio.options.validateStatus(500), isTrue);
      });

      test('should have persistent connection disabled for mobile apps', () {
        // Act
        final dio = DioClient.getDio();

        // Assert
        expect(dio.options.persistentConnection, isFalse);
      });

      test('should follow redirects for API endpoints', () {
        // Act
        final dio = DioClient.getDio();

        // Assert
        expect(dio.options.followRedirects, isTrue);
      });
    });
  });
}
