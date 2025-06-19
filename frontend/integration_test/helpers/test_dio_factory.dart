import 'package:dio/dio.dart';
import 'package:app/services/network/dio_client.dart';
import 'mock_server.dart';

/// Factory to create a properly mocked Dio instance for tests
class TestDioFactory {
  static Dio? _testDio;
  static MockHttpClientAdapter? _currentAdapter;

  /// Initialize and setup mock Dio with given adapter
  static Dio initializeWithMockAdapter(MockHttpClientAdapter mockAdapter) {
    // Reset any existing instance
    DioClient.resetForTesting();
    _testDio = null;
    _currentAdapter = mockAdapter;

    // Create a new Dio instance with empty base URL for tests
    _testDio = Dio(
      BaseOptions(
        baseUrl: '', // Empty base URL - all paths will be handled by mock
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        persistentConnection: false,
        followRedirects: true,
        validateStatus: (_) => true,
      ),
    );

    // Set the mock adapter
    _testDio!.httpClientAdapter = mockAdapter;

    return _testDio!;
  }

  /// Get the test Dio instance (initializes if needed)
  static Dio getTestDio() {
    if (_testDio == null) {
      // Initialize with empty mock adapter if not already done
      final mockAdapter = MockHttpClientAdapter();
      return initializeWithMockAdapter(mockAdapter);
    }
    return _testDio!;
  }

  /// Update the mock adapter on existing Dio instance
  static void updateMockAdapter(MockHttpClientAdapter mockAdapter) {
    if (_testDio != null) {
      _currentAdapter = mockAdapter;
      _testDio!.httpClientAdapter = mockAdapter;
    }
  }

  /// Reset the test Dio instance
  static void reset() {
    _testDio = null;
    _currentAdapter = null;
    DioClient.resetForTesting();
  }

  /// Verify mock is properly attached
  static bool isMockAttached() {
    return _testDio != null &&
        _testDio!.httpClientAdapter is MockHttpClientAdapter &&
        _testDio!.options.baseUrl.isEmpty;
  }
}
