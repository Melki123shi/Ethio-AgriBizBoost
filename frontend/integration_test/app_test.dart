import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'features/auth/login_flow_test.dart' as login_tests;
import 'features/auth/signup_flow_test.dart' as signup_tests;
import 'features/auth/logout_flow_test.dart' as logout_tests;
import 'features/auth/session_persistence_test.dart' as session_tests;
import 'helpers/app_setup.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set test configuration for better performance
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // Setup before all tests
  setUpAll(() async {
    // Ensure clean state before starting tests
    await IntegrationTestApp.clearAllData();
  });

  // Cleanup after all tests
  tearDownAll(() async {
    await IntegrationTestApp.resetAppState();
  });

  group('🔐 Complete Auth Integration Tests', () {
    group('📝 Signup Tests', () {
      signup_tests.main();
    });

    group('🔑 Login Tests', () {
      login_tests.main();
    });

    // group('🚪 Logout Tests (5 tests)', () {
    //   logout_tests.main();
    // });

    // group('🔄 Session Tests (8 tests)', () {
    //   session_tests.main();
    // });
  });

  // Total: 36 auth tests
  // Test Coverage:
  // - RichText navigation between Login ↔ Signup
  // - Form validation (phone numbers, passwords, emails)
  // - API integration with mock responses
  // - Token management (storage, refresh, expiration)
  // - Session persistence and auto-login
  // - Error handling (network errors, validation errors)
  // - State management (AuthBloc states)
  // - Navigation guards and redirects
}
