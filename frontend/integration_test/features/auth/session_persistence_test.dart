import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_setup.dart';
import '../../helpers/mock_server.dart';
import '../../helpers/test_utils.dart';
import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔄 Auto-Login & Session Persistence Integration Tests', () {
    late MockHttpClientAdapter mockAdapter;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      await IntegrationTestApp.clearAllData();
      mockAdapter = MockHttpClientAdapter();
    });

    tearDown(() async {
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
    });

    testWidgets('should auto-login with valid stored tokens', (tester) async {
      // Setup valid tokens using SharedPreferences directly
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'valid-token',
        'REFRESH_TOKEN': 'valid-refresh',
        'TOKEN_TYPE': 'Bearer',
      });

      // Mock successful profile calls (persistent)
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pumpAndSettle();

      // Ensure auto-login completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should auto-login and be on home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify tokens are still present
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ACCESS_TOKEN'), 'valid-token');
      expect(prefs.getString('REFRESH_TOKEN'), 'valid-refresh');
      expect(prefs.getString('TOKEN_TYPE'), 'Bearer');
    });

    testWidgets('should handle expired token with refresh', (tester) async {
      // Setup tokens using SharedPreferences directly
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'expired-token',
        'REFRESH_TOKEN': 'valid-refresh',
        'TOKEN_TYPE': 'Bearer',
      });

      // Clear and setup mock responses in specific order
      mockAdapter.clearResponses();

      // First profile call returns 401 (expired token)
      mockAdapter
          .addResponse('/auth/profile', 401, {'detail': 'Token expired'});

      // This triggers refresh request
      mockAdapter.addResponse('/auth/refresh', 200, {
        'access_token': 'new-mock-access-token-456',
        'refresh_token': 'new-mock-refresh-token-456',
        'token_type': 'Bearer'
      });

      // After refresh, profile is retried with new token (persistent)
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      // Create app with skip auth to control when auth starts
      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      // Give time for the auth flow to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Ensure navigation completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should still reach home after token refresh
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify new tokens were stored after refresh
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ACCESS_TOKEN'), 'new-mock-access-token-456');
      expect(prefs.getString('REFRESH_TOKEN'), 'new-mock-refresh-token-456');
    });

    testWidgets('should redirect to login when refresh fails', (tester) async {
      // Setup tokens
      await TokenStorage.saveAccessToken('expired-token');
      await TokenStorage.saveRefreshToken('invalid-refresh');
      await TokenStorage.saveTokenType('Bearer');

      // Clear and setup mock responses
      mockAdapter.clearResponses();

      // 1. Initial profile call fails with 401
      mockAdapter
          .addResponse('/auth/profile', 401, {'detail': 'Token expired'});

      // 2. Refresh attempt also fails
      mockAdapter.addResponse(
          '/auth/refresh', 401, {'detail': 'Invalid refresh token'});

      // 3. No retry after failed refresh

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Give time for auth check and refresh attempt
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Ensure redirect completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should redirect to login
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tokens should be cleared
      final accessToken = await TokenStorage.readAccessToken();
      final refreshToken = await TokenStorage.readRefreshToken();
      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });

    testWidgets('should handle no stored tokens on app start', (tester) async {
      // Ensure no tokens are stored
      await IntegrationTestApp.clearAllData();

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pumpAndSettle();

      // Ensure auto-login completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should start at login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify no tokens exist
      expect(await TokenStorage.readAccessToken(), isNull);
      expect(await TokenStorage.readRefreshToken(), isNull);
      expect(await TokenStorage.readTokenType(), isNull);
    });

    testWidgets('should handle corrupted token gracefully', (tester) async {
      // Setup corrupted/invalid token
      await TokenStorage.saveAccessToken('corrupted-token-@#\$%');
      await TokenStorage.saveRefreshToken('corrupted-refresh-@#\$%');
      await TokenStorage.saveTokenType('Bearer');

      // Mock profile call failure
      mockAdapter.addResponse(
          '/auth/profile', 401, {'detail': 'Invalid token format'});

      // Mock refresh failure due to corrupted refresh token
      mockAdapter.addResponse(
          '/auth/refresh', 401, {'detail': 'Invalid refresh token format'});

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Ensure redirect completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should redirect to login
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tokens should be cleared
      expect(await TokenStorage.readAccessToken(), isNull);
      expect(await TokenStorage.readRefreshToken(), isNull);
    });

    testWidgets('should maintain session across app restarts', (tester) async {
      // First app session - save tokens
      await TokenStorage.saveAccessToken('persistent-token');
      await TokenStorage.saveRefreshToken('persistent-refresh');
      await TokenStorage.saveTokenType('Bearer');

      // Mock successful profile calls
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pumpAndSettle();

      // Ensure auto-login completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should be logged in
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify tokens are still there before creating new app
      expect(await TokenStorage.readAccessToken(), 'persistent-token');
      expect(await TokenStorage.readRefreshToken(), 'persistent-refresh');
      expect(await TokenStorage.readTokenType(), 'Bearer');

      // Create new app instance (simulating restart)
      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check for the new instance
      final newAuthBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      newAuthBloc.add(AppStarted());

      await tester.pumpAndSettle();

      // Ensure auto-login completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should still be logged in
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tokens should still be there
      expect(await TokenStorage.readAccessToken(), 'persistent-token');
      expect(await TokenStorage.readRefreshToken(), 'persistent-refresh');
    });

    testWidgets('should handle token refresh during active session',
        (tester) async {
      // Setup initial valid tokens
      await TokenStorage.saveAccessToken('initial-token');
      await TokenStorage.saveRefreshToken('initial-refresh');
      await TokenStorage.saveTokenType('Bearer');

      // Mock successful initial profile calls (persistent)
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pumpAndSettle();

      // Ensure auto-login completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should be logged in
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify initial tokens are still there
      expect(await TokenStorage.readAccessToken(), 'initial-token');
    });

    testWidgets('should clear tokens when user is unauthorized',
        (tester) async {
      // Setup tokens
      await TokenStorage.saveAccessToken('unauthorized-token');
      await TokenStorage.saveRefreshToken('unauthorized-refresh');
      await TokenStorage.saveTokenType('Bearer');

      // Mock 403 Forbidden response (user is banned/unauthorized)
      mockAdapter.addResponse(
          '/auth/profile', 403, {'detail': 'User account suspended'});

      await tester.pumpWidget(IntegrationTestApp.createAppWithMockAdapter(
          mockAdapter,
          skipAuth: true));

      // Now trigger auth check after mocks are set up
      final authBloc =
          tester.element(find.byType(MaterialApp)).read<AuthBloc>();
      authBloc.add(AppStarted());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Ensure redirect completes
      await TestUtils.ensureNavigationComplete(tester);

      // Should redirect to login
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tokens should be cleared
      expect(await TokenStorage.readAccessToken(), isNull);
      expect(await TokenStorage.readRefreshToken(), isNull);
    });
  });
}
