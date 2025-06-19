import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_setup.dart';
import '../../helpers/mock_server.dart';
import '../../helpers/navigation_helpers.dart';
import '../../helpers/test_utils.dart';
import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔑 Login Flow Integration Tests', () {
    late MockHttpClientAdapter mockAdapter;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      await IntegrationTestApp.clearAllData();
      mockAdapter = MockHttpClientAdapter();

      // Setup common API responses for login tests
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );
    });

    tearDown(() async {
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
    });

    testWidgets('should display login screen correctly', (tester) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Login'), findsAtLeastNWidgets(1));

      // Verify form fields
      expect(
        find.widgetWithText(TextFormField, 'Enter your phone number'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'Enter your password'),
        findsOneWidget,
      );

      // Verify login button
      expect(find.byType(LoadingButton), findsOneWidget);

      // Verify sign up link
      expect(find.byType(RichText), findsAtLeastNWidgets(1));
    });

    testWidgets('should complete login flow successfully', (tester) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Fill login form
      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Ensure the button is visible before tapping
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.byType(LoadingButton));

      // Wait for the request to complete
      await tester.pumpAndSettle();

      // Additional wait for navigation to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should navigate to home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify tokens were stored
      final accessToken = await TokenStorage.readAccessToken();
      final refreshToken = await TokenStorage.readRefreshToken();
      final tokenType = await TokenStorage.readTokenType();

      expect(accessToken, 'mock-access-token-123');
      expect(refreshToken, 'mock-refresh-token-123');
      expect(tokenType, 'Bearer');

      // Verify API was called correctly
      final loginRequest = mockAdapter.requests
          .where((r) => r.path == '/auth/login-with-json')
          .firstOrNull;

      expect(loginRequest, isNotNull);
      expect(loginRequest!.method, 'POST');
      expect(loginRequest.data['phone_number'], '0911234567');
      expect(loginRequest.data['password'], 'Password123');
    });

    testWidgets('should show validation errors for invalid input', (
      tester,
    ) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Test empty form submission
      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Please correct the highlighted fields.'),
        findsOneWidget,
      );

      // Fill invalid credentials
      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: 'invalid',
        password: 'short',
        clearFirst: true,
      );

      await tester.pumpAndSettle();
      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check for validation errors
      expect(
        find.text('Enter a valid Ethiopian phone number.'),
        findsOneWidget,
      );
      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('should handle phone number formats correctly', (tester) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Test various phone number formats
      final validPhoneNumbers = [
        '0911234567', // Local format
        '+251911234567', // International format
        '091 123 4567', // With spaces
      ];

      for (final phoneNumber in validPhoneNumbers) {
        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: phoneNumber,
          password: 'ValidPassword123',
          clearFirst: true,
        );

        // Trigger validation by tapping outside
        await tester.tap(find.byType(LoginScreen).first);
        await tester.pump();

        // Should not show phone validation error
        expect(
          find.text('Enter a valid Ethiopian phone number.'),
          findsNothing,
        );
      }
    });

    testWidgets('should handle incorrect credentials error', (tester) async {
      // Override mock response for this test
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        401,
        MockApiResponses.loginError(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'WrongPassword',
      );

      // Ensure button is visible
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');

      // Wait for error message using improved utility
      await TestUtils.waitForSnackBar(tester, 'Invalid credentials');

      // Should remain on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle network error during login', (tester) async {
      // Override mock to simulate network error
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        500,
        MockApiResponses.networkError(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Ensure button is visible
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');

      // Wait for error message
      await TestUtils.waitForSnackBar(tester, 'Internal server error');

      // Should remain on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Wait for error SnackBar to disappear before retry
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Test retry after error
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      // Ensure button is visible for retry
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');

      // Wait for successful navigation
      await tester.pumpAndSettle();
      await TestUtils.ensureNavigationComplete(tester);

      // Should succeed on retry
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should navigate to signup screen when link is tapped', (
      tester,
    ) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Verify navigation
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle auth state transitions correctly', (
      tester,
    ) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Get auth bloc after ensuring we're on the correct screen
      final BuildContext loginContext =
          tester.element(find.byType(LoginScreen));
      final authBloc = loginContext.read<AuthBloc>();

      // Should start in initial state
      expect(authBloc.state, isA<AuthInitial>());

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Submit form and wait for completion
      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
      await tester.pumpAndSettle();

      // Wait for navigation to complete
      await TestUtils.ensureNavigationComplete(tester);

      // Verify we navigated to home screen (auth success)
      expect(find.byType(HomeScreen), findsOneWidget);

      // The final state should be success after successful navigation
      expect(authBloc.state, isA<AuthSuccess>());
    });

    testWidgets('should prevent back navigation after successful login', (
      tester,
    ) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Login
      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
      await tester.pumpAndSettle();

      // Additional wait for navigation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should be on home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Try to go back (simulate back button)
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      expect(navigator.canPop(), isFalse);
    });

    testWidgets('should clear form on error and allow retry', (tester) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});

      // First attempt with wrong credentials
      mockAdapter.addResponse(
        '/auth/login-with-json',
        401,
        MockApiResponses.loginError(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'WrongPassword',
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');

      // Wait for error
      await TestUtils.waitForSnackBar(tester, 'Invalid credentials');

      // Wait for SnackBar to disappear
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Setup successful response for retry
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      // Fill form again with correct credentials
      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'CorrectPassword',
        clearFirst: true,
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
      await tester.pumpAndSettle();

      // Ensure navigation is complete
      await TestUtils.ensureNavigationComplete(tester);

      // Should succeed
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should properly handle button state during authentication', (
      tester,
    ) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      // Fill the form
      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Verify button is enabled before submission
      final loadingButtonBefore =
          tester.widget<LoadingButton>(find.byType(LoadingButton));
      expect(loadingButtonBefore.loading, isFalse);

      // Submit form
      await tester.tap(find.byType(LoadingButton));

      // Complete the authentication flow
      await tester.pumpAndSettle();

      // Verify successful navigation
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle rapid form submissions gracefully', (
      tester,
    ) async {
      // Set up profile response for app startup (unauthorized)
      mockAdapter.clearResponses();
      mockAdapter.addResponse('/auth/profile', 401, {'detail': 'Unauthorized'});
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addPersistentResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      await tester
          .pumpWidget(IntegrationTestApp.createAppWithMockAdapter(mockAdapter));
      await tester.pumpAndSettle();

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Try to tap button multiple times rapidly
      final loadingButton = find.byType(LoadingButton);
      await tester.tap(loadingButton);
      await tester.pump();

      // Try to tap again while loading - should be ignored
      await tester.tap(loadingButton, warnIfMissed: false);
      await tester.pump();

      // Should only make one API call
      await tester.pumpAndSettle();

      final loginRequests = mockAdapter.requests
          .where((r) => r.path == '/auth/login-with-json')
          .toList();

      expect(loginRequests.length, 1);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
