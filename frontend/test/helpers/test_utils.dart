// import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Shared test utilities and helpers
class TestUtils {
  /// Common setup for all tests
  static void setUpAll() {
    // Add any global test setup here
  }

  /// Clean up after tests
  static void tearDownAll() {
    // Add any global test cleanup here
  }

  /// Helper to verify no unexpected interactions with mocks
  static void verifyNoMoreInteractionsOnMocks(List<Mock> mocks) {
    for (final mock in mocks) {
      verifyNoMoreInteractions(mock);
    }
  }

  /// Helper to reset all mocks
  static void resetMocks(List<Mock> mocks) {
    for (final mock in mocks) {
      reset(mock);
    }
  }
}
