import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
// import 'package:mockito/mockito.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  final Map<String, List<dynamic>> _responses = {};
  final List<RequestRecord> _requests = [];
  final Map<String, bool> _consumeResponse = {};

  void addResponse(String path, int statusCode, Map<String, dynamic> data,
      {bool consumeOnUse = true}) {
    _responses.putIfAbsent(path, () => []).add({
      'statusCode': statusCode,
      'data': data,
    });
    _consumeResponse[path] = consumeOnUse;
  }

  void clearResponses() {
    _responses.clear();
    _requests.clear();
    _consumeResponse.clear();
  }

  List<RequestRecord> get requests => List.unmodifiable(_requests);

  /// Add a response that will be reused for multiple calls
  void addPersistentResponse(
      String path, int statusCode, Map<String, dynamic> data) {
    addResponse(path, statusCode, data, consumeOnUse: false);
  }

  /// Add multiple identical responses for a path
  void addMultipleResponses(
      String path, int statusCode, Map<String, dynamic> data, int count) {
    for (int i = 0; i < count; i++) {
      addResponse(path, statusCode, data, consumeOnUse: true);
    }
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Extract path from the full URL if needed
    String path = options.path;
    if (path.startsWith('http')) {
      // Extract path from full URL
      final uri = Uri.parse(path);
      path = uri.path;
    }

    // Record the request with clean path
    _requests.add(RequestRecord(
      method: options.method,
      path: path,
      data: options.data,
      headers: options.headers,
    ));

    // Find matching response using clean path
    final responseList = _responses[path];
    if (responseList != null && responseList.isNotEmpty) {
      // Check if we should consume the response
      final shouldConsume = _consumeResponse[path] ?? true;

      // Get the response (either remove it or keep it)
      final response = shouldConsume && responseList.length > 1
          ? responseList.removeAt(0)
          : responseList.first;

      final statusCode = response['statusCode'] as int;
      final data = response['data'] as Map<String, dynamic>;

      return ResponseBody.fromString(
        jsonEncode(data),
        statusCode,
        headers: {
          'content-type': ['application/json'],
        },
      );
    }

    // Default to 404 if no mock response found
    throw DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 404,
        statusMessage: 'Not Found',
        data: {'detail': 'Mock endpoint not found: $path'},
      ),
    );
  }

  @override
  void close({bool force = false}) {
    // No-op for mock
  }
}

class RequestRecord {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic> headers;

  RequestRecord({
    required this.method,
    required this.path,
    required this.data,
    required this.headers,
  });

  @override
  String toString() {
    return '$method $path - Data: $data';
  }
}

class MockApiResponses {
  static Map<String, dynamic> successfulSignup() => {
        'user_id': 'test-user-id-123',
        'message': 'User registered successfully',
      };

  static Map<String, dynamic> successfulLogin() => {
        'access_token': 'mock-access-token-123',
        'refresh_token': 'mock-refresh-token-123',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };

  static Map<String, dynamic> signupError(
          {String message = 'Phone number already exists'}) =>
      {
        'detail': message,
      };

  static Map<String, dynamic> loginError(
          {String message = 'Invalid credentials'}) =>
      {
        'detail': message,
      };

  static Map<String, dynamic> refreshTokenSuccess() => {
        'access_token': 'new-mock-access-token-456',
        'refresh_token': 'new-mock-refresh-token-456',
        'token_type': 'Bearer',
        'expires_in': 3600,
      };

  static Map<String, dynamic> logoutSuccess() => {
        'message': 'Logged out successfully',
      };

  static Map<String, dynamic> userProfile() => {
        'id': 'test-user-id-123',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone_number': '0911234567',
        'location': 'Addis Ababa, Ethiopia',
        'profile_picture_url': 'assets/images/profile_placeholder.png',
        'created_at': '2025-06-19T00:00:00Z',
      };

  static Map<String, dynamic> profileError(
          {String message = 'Profile not found'}) =>
      {
        'detail': message,
      };

  static Map<String, dynamic> networkError() => {
        'detail': 'Internal server error',
      };

  static Map<String, dynamic> validationError(
          {String message = 'Validation failed'}) =>
      {
        'detail': message,
        'errors': {
          'phone_number': ['Invalid phone number format'],
        },
      };
}
