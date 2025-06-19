import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_setup.dart';
import 'mock_server.dart';
import 'test_dio_factory.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Mock Setup Verification', () {
    testWidgets('verify mock adapter is properly attached', (tester) async {
      // Create mock adapter
      final mockAdapter = MockHttpClientAdapter();

      // Add test response
      mockAdapter.addResponse('/test', 200, {'message': 'Mock works!'});

      // Create app with mock adapter
      await tester.pumpWidget(
        IntegrationTestApp.createAppWithMockAdapter(mockAdapter),
      );
      await tester.pumpAndSettle();

      // Verify mock is attached
      expect(TestDioFactory.isMockAttached(), isTrue);

      // Verify test dio has empty base URL
      final testDio = TestDioFactory.getTestDio();
      expect(testDio.options.baseUrl, isEmpty);

      // Make a test request to verify mock is working
      final response = await testDio.get('/test');
      expect(response.statusCode, 200);
      expect(response.data['message'], 'Mock works!');

      // Verify the request was captured by mock
      expect(mockAdapter.requests.length, 1);
      expect(mockAdapter.requests.first.path, '/test');
    });
  });
}
