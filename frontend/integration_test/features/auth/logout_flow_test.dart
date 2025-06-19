import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/presentation/ui/profile/profile_screen.dart';
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

// Helper function to navigate to profile screen
Future<void> navigateToProfileScreen(WidgetTester tester) async {
  // Method 1: Try icon in bottom navigation
  var profileIcon = find.byIcon(Icons.person);

  if (profileIcon.evaluate().isEmpty) {
    // Method 2: Try to find Icon widget
    profileIcon = find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.person,
    );
  }

  if (profileIcon.evaluate().isEmpty) {
    // Method 3: Try bottom navigation bar items
    final bottomNav = find.byType(BottomNavigationBar);
    if (bottomNav.evaluate().isNotEmpty) {
      final navBar = tester.widget<BottomNavigationBar>(bottomNav);
      // Find profile item (usually has person icon)
      for (int i = 0; i < navBar.items.length; i++) {
        final item = navBar.items[i];
        if (item.icon is Icon && (item.icon as Icon).icon == Icons.person) {
          // Tap by position
          final navItemFinder = find.byType(BottomNavigationBar);
          final RenderBox box = tester.renderObject(navItemFinder);
          final itemWidth = box.size.width / navBar.items.length;
          final tapX = itemWidth * i + itemWidth / 2;
          final tapPoint = box.localToGlobal(Offset(tapX, box.size.height / 2));
          await tester.tapAt(tapPoint);
          break;
        }
      }
    }
  } else {
    await tester.tap(profileIcon.first);
  }

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🚪 Logout Flow Integration Tests', () {
    late MockHttpClientAdapter mockAdapter;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Reset SharedPreferences mock before each test
      SharedPreferences.setMockInitialValues({});
      await IntegrationTestApp.clearAllData();
      mockAdapter = MockHttpClientAdapter();
    });

    tearDown(() async {
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
      // Ensure SharedPreferences is reset
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should complete logout flow successfully', (tester) async {
      // Setup: User is logged in
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'mock_access_token',
        'REFRESH_TOKEN': 'mock_refresh_token',
        'TOKEN_TYPE': 'Bearer',
      });

      // Mock successful profile responses (reusable for multiple calls)
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      // Mock successful logout
      mockAdapter.addResponse(
          '/auth/logout', 200, MockApiResponses.logoutSuccess());

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

      // Should start at home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile - try multiple methods
      await navigateToProfileScreen(tester);

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

      // Wait for logout to process
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should navigate to login after logout
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify tokens are cleared from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ACCESS_TOKEN'), isNull);
      expect(prefs.getString('REFRESH_TOKEN'), isNull);
      expect(prefs.getString('TOKEN_TYPE'), isNull);

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
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'mock_access_token',
        'REFRESH_TOKEN': 'mock_refresh_token',
        'TOKEN_TYPE': 'Bearer',
      });

      // Mock successful profile responses (reusable for multiple calls)
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      // Mock failed logout
      mockAdapter.addResponse('/auth/logout', 500, {'detail': 'Logout failed'});

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

      // Should start at home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile
      await navigateToProfileScreen(tester);

      // Verify we're on profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);

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
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Even though logout failed on server, user should be logged out locally
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify tokens are cleared locally
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ACCESS_TOKEN'), isNull);
      expect(prefs.getString('REFRESH_TOKEN'), isNull);
    });

    testWidgets('should clear all user data on logout', (tester) async {
      // Setup: User is logged in with data
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'mock_access_token',
        'REFRESH_TOKEN': 'mock_refresh_token',
        'TOKEN_TYPE': 'Bearer',
      });

      // Mock profile responses
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      // Mock successful logout
      mockAdapter.addResponse(
          '/auth/logout', 200, MockApiResponses.logoutSuccess());

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

      // Navigate to profile
      await navigateToProfileScreen(tester);

      // Verify we're on profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);

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

      // Wait for navigation and logout to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify all auth data is cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ACCESS_TOKEN'), isNull);
      expect(prefs.getString('REFRESH_TOKEN'), isNull);
      expect(prefs.getString('TOKEN_TYPE'), isNull);

      // Should be on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle logout with no network connection',
        (tester) async {
      // Setup: User is logged in
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'mock_access_token',
        'REFRESH_TOKEN': 'mock_refresh_token',
        'TOKEN_TYPE': 'Bearer',
      });

      // Mock profile responses
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());

      // Don't add any logout response to simulate network failure
      // The logout request will fail but app should still logout locally

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

      // Navigate to profile
      await navigateToProfileScreen(tester);

      // Verify we're on profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);

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
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Should still logout locally even if network fails
      expect(find.byType(LoginScreen), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ACCESS_TOKEN'), isNull);
      expect(prefs.getString('REFRESH_TOKEN'), isNull);
    });

    testWidgets('should prevent access to authenticated screens after logout',
        (tester) async {
      // Setup: User is logged in
      SharedPreferences.setMockInitialValues({
        'ACCESS_TOKEN': 'mock_access_token',
        'REFRESH_TOKEN': 'mock_refresh_token',
        'TOKEN_TYPE': 'Bearer',
      });

      // Mock responses
      mockAdapter.addPersistentResponse(
          '/auth/profile', 200, MockApiResponses.userProfile());
      mockAdapter.addResponse(
          '/auth/logout', 200, MockApiResponses.logoutSuccess());

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

      // Verify we're on home screen initially
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile
      await navigateToProfileScreen(tester);

      // Verify we're on profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Find and tap logout
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
      await tester.pump(const Duration(seconds: 1));
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
