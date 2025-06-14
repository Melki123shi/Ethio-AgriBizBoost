import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'features/auth/auth_flow_test.dart' as auth_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
    auth_tests.main();
  });
}
