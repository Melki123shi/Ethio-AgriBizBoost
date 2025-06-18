import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/services/network/dio_client.dart';
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
      DioClient.resetForTesting();
      DioClient.getDio().httpClientAdapter = mockAdapter;

      // Setup common API responses for login tests
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addResponse(
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
      await tester.pumpWidget(IntegrationTestApp.createApp());
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
      await tester.pumpWidget(IntegrationTestApp.createApp());
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

      // Check loading state when submitting
      await tester.tap(find.byType(LoadingButton));
      await tester.pump(); // Don't settle to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Get auth bloc to check state
      final authBloc =
          tester.element(find.byType(LoginScreen)).read<AuthBloc>();
      expect(authBloc.state, isA<AuthLoading>());

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
      await tester.pumpWidget(IntegrationTestApp.createApp());
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
      await tester.pumpWidget(IntegrationTestApp.createApp());
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
      mockAdapter.addResponse(
        '/auth/login-with-json',
        401,
        MockApiResponses.loginError(),
      );

      await tester.pumpWidget(IntegrationTestApp.createApp());
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

      // Wait for the error SnackBar to appear
      await tester.pump(); // Start the SnackBar animation
      await tester.pump(const Duration(milliseconds: 750)); // Let it animate

      // Check auth state
      final authBloc =
          tester.element(find.byType(LoginScreen)).read<AuthBloc>();
      print('Auth state after error: ${authBloc.state}');
      if (authBloc.state is AuthFailure) {
        print(
          'Auth failure message: ${(authBloc.state as AuthFailure).errorMessage}',
        );
      }

      // Debug: Print all text widgets to see what's shown
      final textWidgets = find.byType(Text).evaluate();
      print('Total text widgets found: ${textWidgets.length}');
      for (final element in textWidgets) {
        final widget = element.widget as Text;
        if (widget.data != null) {
          print('Text widget: "${widget.data}"');
        }
      }

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);

      // Should remain on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.pumpAndSettle(); // Complete animations
    });

    testWidgets('should handle network error during login', (tester) async {
      // Override mock to simulate network error
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
        '/auth/login-with-json',
        500,
        MockApiResponses.networkError(),
      );

      await tester.pumpWidget(IntegrationTestApp.createApp());
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

      // Wait for error SnackBar
      await tester.pump(); // Start the SnackBar animation
      await tester.pump(const Duration(milliseconds: 500)); // Let it animate

      // Should show error message
      expect(find.text('Internal server error'), findsOneWidget);

      // Should remain on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.pumpAndSettle(); // Complete animations

      // Wait for error SnackBar to disappear before retry
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Test retry after error
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addResponse(
        '/auth/profile',
        200,
        MockApiResponses.userProfile(),
      );

      // Ensure button is visible for retry
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');

      // Wait for the request to complete and state to update
      await tester.pumpAndSettle();

      // Additional wait for navigation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should succeed on retry
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should navigate to signup screen when link is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
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
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Get auth bloc
      final authBloc =
          tester.element(find.byType(LoginScreen)).read<AuthBloc>();

      // Should start in initial state
      expect(authBloc.state, isA<AuthInitial>());

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Ensure form is visible and can be interacted with
      final loadingButton = find.byType(LoadingButton);
      await tester.ensureVisible(loadingButton);
      await tester.pumpAndSettle();

      // Start login - tap directly without helper to control timing
      await tester.tap(loadingButton, warnIfMissed: false);

      // Immediately pump to process the tap and trigger loading state
      await tester.pump();

      // Should transition to loading
      expect(authBloc.state, isA<AuthLoading>());

      await tester.pumpAndSettle();

      // Should transition to success
      expect(authBloc.state, isA<AuthSuccess>());
    });

    testWidgets('should prevent back navigation after successful login', (
      tester,
    ) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
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
      // First attempt with wrong credentials
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
        '/auth/login-with-json',
        401,
        MockApiResponses.loginError(),
      );

      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'WrongPassword',
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Login');

      // Wait for error SnackBar
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      // Error should be shown
      expect(find.text('Invalid credentials'), findsOneWidget);

      await tester.pumpAndSettle();

      // Wait for SnackBar to disappear
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Setup successful response for retry
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
        '/auth/login-with-json',
        200,
        MockApiResponses.successfulLogin(),
      );
      mockAdapter.addResponse(
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

      // Additional wait for navigation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should succeed
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should show loading state during authentication', (
      tester,
    ) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      await TestUtils.fillLoginForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Ensure button is visible
      final loadingButton = find.byType(LoadingButton);
      await tester.ensureVisible(loadingButton);
      await tester.pumpAndSettle();

      // Tap and immediately check for loading
      await tester.tap(loadingButton);
      await tester.pump(); // Single pump to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // The button should be disabled during loading
      // Get the button widget AFTER it has been updated with loading state
      final LoadingButton button = tester.widget(find.byType(LoadingButton));
      expect(button.loading, isTrue);
      // The onPressed should be null when loading is true
      expect(button.onPressed, isNotNull); // The callback exists
      // But the actual ElevatedButton should be disabled
      final elevatedButton = find.byType(ElevatedButton);
      final ElevatedButton elevatedButtonWidget = tester.widget(elevatedButton);
      expect(elevatedButtonWidget.onPressed, isNull); // Should be disabled

      await tester.pumpAndSettle();
    });

    testWidgets('should handle rapid form submissions gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
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
