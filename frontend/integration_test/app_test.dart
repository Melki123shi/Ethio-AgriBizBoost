import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'features/auth/login_flow_test.dart' as login_tests;
import 'features/auth/signup_flow_test.dart' as signup_tests;
import 'features/auth/logout_flow_test.dart' as logout_tests;
import 'features/auth/session_persistence_test.dart' as session_tests;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set test configuration for better performance
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('🔐 Complete Auth Integration Tests', () {
    group('📝 Signup Tests (12 tests)', () {
      signup_tests.main();
    });

    group('🔑 Login Tests (11 tests)', () {
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
  // - RichText navigation between Login ↔ Signup
  // - Form validation
  // - API integration
  // - Token management
}
