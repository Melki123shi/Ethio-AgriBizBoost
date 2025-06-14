import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mock_server.dart';
import '../../helpers/test_utils.dart';
import 'test_data.dart';

/// Authentication-specific test helpers
class AuthTestHelpers {
  /// Verify that the user is on the login screen
  static void verifyOnLoginScreen(WidgetTester tester) {
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login'), findsAtLeastNWidgets(1));
    expect(find.text("Don't have an account?"), findsOneWidget);
  }

  /// Verify that the user is on the signup screen
  static void verifyOnSignupScreen(WidgetTester tester) {
    expect(find.byType(SignupScreen), findsOneWidget);
    expect(find.text('Sign Up'), findsAtLeastNWidgets(1));
    expect(find.text("Already have an account?"), findsOneWidget);
  }

  /// Verify that the user is on the home screen
  static void verifyOnHomeScreen(WidgetTester tester) {
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(SignupScreen), findsNothing);
  }

  /// Verify that tokens are stored correctly
  static Future<void> verifyTokensStored({
    required String expectedAccessToken,
    required String expectedRefreshToken,
    String expectedTokenType = 'Bearer',
  }) async {
    final accessToken = await TokenStorage.readAccessToken();
    final refreshToken = await TokenStorage.readRefreshToken();
    final tokenType = await TokenStorage.readTokenType();

    expect(accessToken, expectedAccessToken);
    expect(refreshToken, expectedRefreshToken);
    expect(tokenType, expectedTokenType);
  }

  /// Verify that tokens are cleared
  static Future<void> verifyTokensCleared() async {
    final accessToken = await TokenStorage.readAccessToken();
    final refreshToken = await TokenStorage.readRefreshToken();
    final tokenType = await TokenStorage.readTokenType();

    expect(accessToken, isNull);
    expect(refreshToken, isNull);
    expect(tokenType, isNull);
  }

  /// Verify API request was made with correct data
  static void verifyApiRequest({
    required MockHttpClientAdapter mockAdapter,
    required String path,
    required String method,
    required Map<String, dynamic> expectedData,
  }) {
    final request = mockAdapter.requests
        .where((r) => r.path == path && r.method == method)
        .firstOrNull;

    expect(request, isNotNull, reason: 'API request to $path not found');

    expectedData.forEach((key, value) {
      expect(request!.data[key], value,
          reason: 'Expected $key to be $value but got ${request.data[key]}');
    });
  }

  /// Get the current auth state
  static AuthState getCurrentAuthState(WidgetTester tester) {
    final context = tester.element(find.byType(MaterialApp));
    return context.read<AuthBloc>().state;
  }

  /// Get the current user state
  static UserState getCurrentUserState(WidgetTester tester) {
    final context = tester.element(find.byType(MaterialApp));
    return context.read<UserBloc>().state;
  }

  /// Perform complete signup flow
  static Future<void> performSignup(
    WidgetTester tester, {
    String? name,
    required String phoneNumber,
    String? email,
    required String password,
  }) async {
    await TestUtils.tapButton(tester, 'Sign Up');
    await tester.pumpAndSettle();

    await TestUtils.fillSignupForm(
      tester,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
    );

    await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
    await tester.pumpAndSettle();
  }

  /// Perform complete login flow
  static Future<void> performLogin(
    WidgetTester tester, {
    required String phoneNumber,
    required String password,
  }) async {
    await TestUtils.fillLoginForm(
      tester,
      phoneNumber: phoneNumber,
      password: password,
    );

    await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
    await tester.pumpAndSettle();
  }

  /// Perform complete logout flow
  static Future<void> performLogout(WidgetTester tester) async {
    await TestUtils.navigateToProfile(tester);

    final logoutOption = find.text('Log out');
    expect(logoutOption, findsOneWidget);
    await tester.tap(logoutOption);
    await tester.pumpAndSettle();

    await TestUtils.tapLoadingButtonByLabel(tester, 'Log out');
    await tester.pumpAndSettle();
  }

  /// Setup mock responses for successful authentication flow
  static void setupSuccessfulAuthMocks(MockHttpClientAdapter mockAdapter) {
    mockAdapter.addResponse(
        '/auth/register', 201, MockApiResponses.successfulSignup());
    mockAdapter.addResponse(
        '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
    mockAdapter.addResponse(
        '/auth/profile', 200, MockApiResponses.userProfile());
    mockAdapter.addResponse(
        '/auth/logout', 200, MockApiResponses.logoutSuccess());
    mockAdapter.addResponse(
        '/auth/refresh', 200, MockApiResponses.refreshTokenSuccess());
  }

  /// Test validation for a specific field
  static Future<void> testFieldValidation(
    WidgetTester tester, {
    required String fieldHint,
    required String invalidValue,
    required String expectedError,
    Map<String, String> otherFields = const {},
  }) async {
    // Fill other required fields with valid values
    for (final entry in otherFields.entries) {
      await TestUtils.fillField(tester, entry.key, entry.value);
    }

    // Fill the field under test with invalid value
    await TestUtils.fillField(tester, fieldHint, invalidValue);

    // Submit form
    await TestUtils.tapLoadingButton(tester);
    await tester.pump();

    // Verify error message
    expect(find.text(expectedError), findsOneWidget);
  }

  /// Test multiple phone number formats
  static Future<void> testPhoneNumberFormats(
    WidgetTester tester, {
    required List<String> validFormats,
    required List<String> invalidFormats,
  }) async {
    // Test valid formats
    for (final phone in validFormats) {
      await TestUtils.fillField(tester, 'Enter your phone number', phone);
      await TestUtils.fillField(
          tester, 'Enter your password', AuthTestData.validPassword);

      await TestUtils.tapLoadingButton(tester);
      await tester.pump();

      expect(
        find.text(AuthTestData.phoneValidationError),
        findsNothing,
        reason: 'Phone number $phone should be valid',
      );
    }

    // Test invalid formats
    for (final phone in invalidFormats) {
      await TestUtils.fillField(tester, 'Enter your phone number', phone);

      await TestUtils.tapLoadingButton(tester);
      await tester.pump();

      expect(
        find.text(AuthTestData.phoneValidationError),
        findsOneWidget,
        reason: 'Phone number $phone should be invalid',
      );
    }
  }

  /// Verify loading state behavior
  static Future<void> verifyLoadingStateBehavior(
    WidgetTester tester,
    Future<void> Function() triggerAction,
  ) async {
    // Trigger the action
    await triggerAction();

    // Immediately check for loading state (don't settle)
    await tester.pump();

    // Should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Button should be disabled
    final button =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(button.onPressed, isNull,
        reason: 'Button should be disabled during loading');

    // Wait for completion
    await tester.pumpAndSettle();

    // Loading should be gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  /// Test network error recovery
  static Future<void> testNetworkErrorRecovery(
    WidgetTester tester, {
    required MockHttpClientAdapter mockAdapter,
    required String endpoint,
    required Map<String, dynamic> errorResponse,
    required Map<String, dynamic> successResponse,
    required Future<void> Function() performAction,
    required String expectedErrorMessage,
  }) async {
    // First attempt fails
    mockAdapter.clearResponses();
    mockAdapter.addResponse(endpoint, 500, errorResponse);

    await performAction();
    await tester.pumpAndSettle();

    // Should show error
    expect(find.text(expectedErrorMessage), findsOneWidget);

    // Setup success for retry
    mockAdapter.clearResponses();
    mockAdapter.addResponse(endpoint, 200, successResponse);

    // Retry
    await performAction();
    await tester.pumpAndSettle();

    // Should succeed
    expect(find.text(expectedErrorMessage), findsNothing);
  }

  /// Verify form state after validation error
  static void verifyFormStateAfterError(WidgetTester tester) {
    // Form should still be visible
    expect(find.byType(Form), findsOneWidget);

    // All form fields should still be present
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2));

    // Submit button should still be present and enabled
    expect(find.byType(LoadingButton), findsOneWidget);
  }

  /// Test complete authentication cycle
  static Future<void> testCompleteAuthCycle(
    WidgetTester tester, {
    required MockHttpClientAdapter mockAdapter,
    required Map<String, dynamic> userData,
  }) async {
    setupSuccessfulAuthMocks(mockAdapter);

    // Signup
    await performSignup(
      tester,
      name: userData['name'],
      phoneNumber: userData['phone'],
      email: userData['email'],
      password: userData['password'],
    );

    expect(find.text(AuthTestData.signupSuccessMessage), findsOneWidget);
    verifyOnLoginScreen(tester);

    // Login
    await performLogin(
      tester,
      phoneNumber: userData['phone'],
      password: userData['password'],
    );

    await verifyTokensStored(
      expectedAccessToken: AuthTestData.mockAccessToken,
      expectedRefreshToken: AuthTestData.mockRefreshToken,
    );
    verifyOnHomeScreen(tester);

    // Logout
    await performLogout(tester);

    await verifyTokensCleared();
    verifyOnLoginScreen(tester);
  }
}
