import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/presentation/ui/profile/profile_screen.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_setup.dart';
import '../../helpers/mock_server.dart';
import '../../helpers/test_utils.dart';
import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🚪 Logout Flow Integration Tests', () {
    late MockHttpClientAdapter mockAdapter;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      await IntegrationTestApp.clearAllData();
      mockAdapter = MockHttpClientAdapter();
      DioClient.resetForTesting();
      DioClient.getDio().httpClientAdapter = mockAdapter;
    });

    tearDown(() async {
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
      DioClient.resetForTesting();
    });

    testWidgets('should complete logout flow successfully', (tester) async {
      // Setup: User is logged in
      await TokenStorage.saveAccessToken('mock_access_token');
      await TokenStorage.saveRefreshToken('mock_refresh_token');
      await TokenStorage.saveTokenType('Bearer');

      // Mock successful profile responses (called multiple times during app startup)
      for (int i = 0; i < 10; i++) {
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
      }

      // Mock successful logout
      mockAdapter.addResponse(
          '/auth/logout', 200, MockApiResponses.logoutSuccess());

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Should start at home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile
      await TestUtils.navigateToProfile(tester);
      await tester.pumpAndSettle();

      // Wait a bit for profile screen to fully load
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we're on profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Find and tap logout option
      final logoutButton = find.text('Log out');
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();

      await tester.tap(logoutButton);

      // Wait for any confirmation dialog or immediate logout
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // If there's a confirmation dialog, handle it
      final confirmButton = find.text('Confirm');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Additional wait for navigation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should navigate to login after logout
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify tokens are cleared
      final accessToken = await TokenStorage.readAccessToken();
      final refreshToken = await TokenStorage.readRefreshToken();
      expect(accessToken, isNull);
      expect(refreshToken, isNull);

      // Verify logout API was called
      final logoutRequest = mockAdapter.requests
          .where((r) => r.path == '/auth/logout')
          .firstOrNull;

      expect(logoutRequest, isNotNull);
      expect(logoutRequest!.method, 'POST');
      expect(logoutRequest.data['refresh_token'], 'mock_refresh_token');
    });

    testWidgets('should handle logout failure gracefully', (tester) async {
      // Setup: User is logged in
      await TokenStorage.saveAccessToken('mock_access_token');
      await TokenStorage.saveRefreshToken('mock_refresh_token');
      await TokenStorage.saveTokenType('Bearer');

      // Mock successful profile responses (called multiple times)
      for (int i = 0; i < 10; i++) {
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
      }

      // Mock failed logout
      mockAdapter.addResponse('/auth/logout', 500, {'detail': 'Logout failed'});

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Should start at home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile
      await TestUtils.navigateToProfile(tester);
      await tester.pumpAndSettle();

      // Wait for profile to load
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap logout option
      final logoutButton = find.text('Log out');
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();

      await tester.tap(logoutButton);

      // Wait for any dialogs or processing
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Handle confirmation if present
      final confirmButton = find.text('Confirm');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pump();
      }

      // Wait for error handling and navigation
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Even though logout failed on server, user should be logged out locally
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify tokens are cleared locally
      final accessToken = await TokenStorage.readAccessToken();
      final refreshToken = await TokenStorage.readRefreshToken();
      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });

    testWidgets('should clear all user data on logout', (tester) async {
      // Setup: User is logged in with data
      await TokenStorage.saveAccessToken('mock_access_token');
      await TokenStorage.saveRefreshToken('mock_refresh_token');
      await TokenStorage.saveTokenType('Bearer');

      // Mock profile responses
      for (int i = 0; i < 10; i++) {
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
      }

      // Mock successful logout
      mockAdapter.addResponse(
          '/auth/logout', 200, MockApiResponses.logoutSuccess());

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Navigate to profile
      await TestUtils.navigateToProfile(tester);
      await tester.pumpAndSettle();

      // Wait for profile to load
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap logout
      final logoutButton = find.text('Log out');
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();

      await tester.tap(logoutButton);

      // Handle any confirmation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final confirmButton = find.text('Confirm');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pump();
      }

      // Wait for navigation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify all auth data is cleared
      expect(await TokenStorage.readAccessToken(), isNull);
      expect(await TokenStorage.readRefreshToken(), isNull);
      expect(await TokenStorage.readTokenType(), isNull);

      // Should be on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle logout with no network connection',
        (tester) async {
      // Setup: User is logged in
      await TokenStorage.saveAccessToken('mock_access_token');
      await TokenStorage.saveRefreshToken('mock_refresh_token');
      await TokenStorage.saveTokenType('Bearer');

      // Mock profile responses
      for (int i = 0; i < 10; i++) {
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
      }

      // Don't add any logout response to simulate network failure
      // The logout request will fail but app should still logout locally

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Navigate to profile
      await TestUtils.navigateToProfile(tester);
      await tester.pumpAndSettle();

      // Wait for profile to load
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap logout
      final logoutButton = find.text('Log out');
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();

      await tester.tap(logoutButton);

      // Handle confirmation and wait for network timeout
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final confirmButton = find.text('Confirm');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pump();
      }

      // Wait for network timeout and error handling
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should still logout locally even if network fails
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await TokenStorage.readAccessToken(), isNull);
      expect(await TokenStorage.readRefreshToken(), isNull);
    });

    testWidgets('should prevent access to authenticated screens after logout',
        (tester) async {
      // Setup: User is logged in
      await TokenStorage.saveAccessToken('mock_access_token');
      await TokenStorage.saveRefreshToken('mock_refresh_token');
      await TokenStorage.saveTokenType('Bearer');

      // Mock responses
      for (int i = 0; i < 10; i++) {
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
      }
      mockAdapter.addResponse(
          '/auth/logout', 200, MockApiResponses.logoutSuccess());

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Verify we're on home screen initially
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile
      await TestUtils.navigateToProfile(tester);
      await tester.pumpAndSettle();

      // Wait for profile to load
      await tester.pump(const Duration(milliseconds: 100));

      // Logout
      final logoutButton = find.text('Log out');
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();

      await tester.tap(logoutButton);

      // Handle confirmation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final confirmButton = find.text('Confirm');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pump();
      }

      // Wait for navigation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Try to navigate to home (should not be possible)
      // In a properly implemented app, this should redirect to login
      // or not allow navigation at all
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);
    });
  });
}
