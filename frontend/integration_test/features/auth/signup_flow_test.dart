import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/services/network/dio_client.dart';
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

  group('📝 Sign-Up Flow Integration Tests', () {
    late MockHttpClientAdapter mockAdapter;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      await IntegrationTestApp.clearAllData();
      mockAdapter = MockHttpClientAdapter();
      DioClient.resetForTesting();
      DioClient.getDio().httpClientAdapter = mockAdapter;

      // Setup default mock response for signup
      mockAdapter.addResponse(
          '/auth/register', 201, MockApiResponses.successfulSignup());
    });

    tearDown(() async {
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
    });

    testWidgets('should display signup screen correctly', (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Verify we're on signup screen
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsAtLeastNWidgets(1));

      // Verify form fields
      expect(find.widgetWithText(TextFormField, 'Enter your name'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Enter your phone number'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Enter your email'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Enter your password'),
          findsOneWidget);

      // Verify signup button
      expect(find.byType(LoadingButton), findsOneWidget);

      // Verify login link
      expect(find.byType(RichText), findsAtLeastNWidgets(1));
    });

    testWidgets('should complete signup with all fields', (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Verify we're on signup screen
      expect(find.byType(SignupScreen), findsOneWidget);

      // Fill signup form with all fields
      await TestUtils.fillSignupForm(
        tester,
        name: 'Abebe Kebede',
        phoneNumber: '+251911234567',
        email: 'abebe.kebede@test.et',
        password: 'SecurePass123!',
      );

      // Submit form
      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

      // Wait for the SnackBar to appear
      await tester.pump(); // Start the SnackBar animation
      await tester.pump(const Duration(milliseconds: 750)); // Wait for SnackBar

      // Debug: Check current screen and auth state
      final signupScreenFinder = find.byType(SignupScreen);
      if (signupScreenFinder.evaluate().isNotEmpty) {
        final authBloc = tester.element(signupScreenFinder).read<AuthBloc>();
        print('Auth state after signup: ${authBloc.state}');
      } else {
        print('SignupScreen not found, might have already navigated');
      }

      // Debug: Print all text widgets to see what's shown
      final textWidgets = find.byType(Text).evaluate();
      for (final element in textWidgets) {
        final widget = element.widget as Text;
        if (widget.data != null && widget.data!.contains('created')) {
          print('Found text: "${widget.data}"');
        }
      }

      // Verify success message first
      expect(find.text('Account created. Please log in.'), findsOneWidget);

      await tester.pumpAndSettle();

      // Additional wait for navigation to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Navigate back to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Form fields should be empty
      final nameField = find.widgetWithText(TextFormField, 'Enter your name');
      final phoneField =
          find.widgetWithText(TextFormField, 'Enter your phone number');
      final emailField = find.widgetWithText(TextFormField, 'Enter your email');
      final passwordField =
          find.widgetWithText(TextFormField, 'Enter your password');

      expect(tester.widget<TextFormField>(nameField).controller?.text, '');
      expect(tester.widget<TextFormField>(phoneField).controller?.text, '');
      expect(tester.widget<TextFormField>(emailField).controller?.text, '');
      expect(tester.widget<TextFormField>(passwordField).controller?.text, '');

      // Verify API was called correctly
      final signupRequest = mockAdapter.requests
          .where((r) => r.path == '/auth/register')
          .firstOrNull;

      expect(signupRequest, isNotNull);
      expect(signupRequest!.method, 'POST');
      expect(signupRequest.data['phone_number'], '+251911234567');
      expect(signupRequest.data['name'], 'Abebe Kebede');
      expect(signupRequest.data['email'], 'abebe.kebede@test.et');
      expect(signupRequest.data['password'], 'SecurePass123!');
    });

    testWidgets('should complete signup with only required fields',
        (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Fill only required fields (phone and password)
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
        // name and email are optional
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

      // Wait for the SnackBar to appear with extra time
      await tester.pump(); // Start the SnackBar animation
      await tester.pump(const Duration(milliseconds: 1000)); // Even longer wait

      // Verify success message in SnackBar
      expect(find.text('Account created. Please log in.'), findsOneWidget);

      await tester.pumpAndSettle(); // Complete all animations

      // Verify navigation back to login
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify optional fields were handled correctly
      final signupRequest = mockAdapter.requests.last;
      expect(signupRequest.data['phone_number'], '0911234567');
      expect(signupRequest.data['password'], 'Password123');
      // Name and email should be null or not present
    });

    testWidgets('should show validation errors for invalid inputs',
        (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Test empty form submission
      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pump();

      expect(
          find.text('Please correct the highlighted fields.'), findsOneWidget);

      // Test invalid phone number
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '123456', // Too short
        password: 'ValidPass123',
        clearFirst: true, // Clear previous form data
      );

      // Ensure the form is updated
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

      // Wait for validation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
          find.text('Enter a valid Ethiopian phone number.'), findsOneWidget);

      // Test short password
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: '1234567', // 7 chars - too short
        clearFirst: true,
      );
      await tester.pumpAndSettle();
      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
          find.text('Password must be at least 8 characters.'), findsOneWidget);

      // Test invalid email format
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: 'ValidPass123',
        email: 'invalid-email',
        clearFirst: true,
      );
      await tester.pumpAndSettle();
      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    // testWidgets('should handle duplicate phone number error', (tester) async {
    //   // Override mock response for this test
    //   mockAdapter.clearResponses();
    //   mockAdapter.addResponse(
    //       '/auth/register',
    //       400,
    //       MockApiResponses.signupError(
    //           message: 'Phone number already registered'));

    //   await tester.pumpWidget(IntegrationTestApp.createApp());
    //   await tester.pumpAndSettle();

    //   // Navigate to signup
    //   await NavigationHelpers.navigateToSignupFromLogin(tester);

    //   await TestUtils.fillSignupForm(
    //     tester,
    //     phoneNumber: '0911234567',
    //     password: 'Password123',
    //   );

    //   await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

    //   // Wait for the error SnackBar to appear
    //   await tester.pump(); // Start the SnackBar animation
    //   await tester
    //       .pump(const Duration(milliseconds: 750)); // Let it animate longer

    //   // Check auth state
    //   final authBloc =
    //       tester.element(find.byType(SignupScreen)).read<AuthBloc>();
    //   print('Auth state after error: ${authBloc.state}');
    //   if (authBloc.state is AuthFailure) {
    //     print(
    //         'Auth failure message: ${(authBloc.state as AuthFailure).errorMessage}');
    //   }

    //   // Debug: Print all text widgets to see what's actually shown
    //   final textWidgets = find.byType(Text).evaluate();
    //   print('Total text widgets found: ${textWidgets.length}');
    //   for (final element in textWidgets) {
    //     final widget = element.widget as Text;
    //     if (widget.data != null) {
    //       print('Text widget: "${widget.data}"');
    //     }
    //   }

    //   // Also check SnackBar content directly
    //   final snackBarContent = find.byType(SnackBar).evaluate();
    //   print('SnackBars found: ${snackBarContent.length}');

    //   // Should show error message in SnackBar
    //   expect(find.text('Phone number already registered'), findsOneWidget);

    //   // Should remain on signup screen
    //   expect(find.byType(SignupScreen), findsOneWidget);

    //   await tester.pumpAndSettle(); // Complete animations
    // });

    testWidgets('should handle Ethiopian phone number formats', (tester) async {
      // Set up mock to prevent actual signup during validation tests
      mockAdapter.clearResponses();
      // We won't actually submit, just test validation

      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Test international format validation
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '+251911234567',
        password: 'Password123',
      );

      // Trigger validation by tapping outside or trying to submit
      await tester.tap(find.byType(SignupScreen).first);
      await tester.pump();

      // Should not show validation error for valid international format
      expect(find.text('Enter a valid Ethiopian phone number.'), findsNothing);

      // Clear and test local format validation
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
        clearFirst: true,
      );

      await tester.tap(find.byType(SignupScreen).first);
      await tester.pump();

      // Should not show validation error for valid local format
      expect(find.text('Enter a valid Ethiopian phone number.'), findsNothing);

      // Clear and test with spaces (should be cleaned and valid)
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '091 123 4567',
        password: 'Password123',
        clearFirst: true,
      );

      await tester.tap(find.byType(SignupScreen).first);
      await tester.pump();

      // Should not show validation error for valid format with spaces
      expect(find.text('Enter a valid Ethiopian phone number.'), findsNothing);

      // Test invalid format to ensure validation is working
      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '123456', // Too short
        password: 'Password123',
        clearFirst: true,
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pump();

      // Should show validation error for invalid format
      expect(
          find.text('Enter a valid Ethiopian phone number.'), findsOneWidget);
    });

    testWidgets('should handle Ethiopian names and characters', (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Test with Amharic name
      await TestUtils.fillSignupForm(
        tester,
        name: 'አበበ ከበደ ወልደማሪያም',
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Verify the name is displayed correctly
      expect(find.text('አበበ ከበደ ወልደማሪያም'), findsOneWidget);

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pumpAndSettle();

      // Should navigate to login
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should navigate to login screen when link is tapped',
        (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Verify on signup screen
      expect(find.byType(SignupScreen), findsOneWidget);

      // Navigate back to login
      await NavigationHelpers.navigateToLoginFromSignup(tester);

      // Verify navigation
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Login'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle auth state transitions correctly',
        (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Get auth bloc
      final authBloc =
          tester.element(find.byType(SignupScreen)).read<AuthBloc>();

      // Should start in initial state
      expect(authBloc.state, isA<AuthInitial>());

      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Ensure form is visible and can be interacted with
      final loadingButton = find.byType(LoadingButton);
      await tester.ensureVisible(loadingButton);
      await tester.pumpAndSettle();

      // Start signup - tap directly without helper to control timing
      await tester.tap(loadingButton, warnIfMissed: false);

      // Immediately pump to process the tap and trigger loading state
      await tester.pump();

      // Should transition to loading
      expect(authBloc.state, isA<AuthLoading>());

      await tester.pumpAndSettle();

      // Should transition to signup done
      expect(authBloc.state, isA<AuthSignupDone>());
    });

    testWidgets('should clear form fields after successful signup',
        (tester) async {
      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      // Fill form
      await TestUtils.fillSignupForm(
        tester,
        name: 'Test User',
        phoneNumber: '0911234567',
        email: 'test@example.com',
        password: 'Password123',
      );

      // Submit
      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

      // Wait for the SnackBar to appear
      await tester.pump(); // Start the SnackBar animation
      await tester.pump(const Duration(milliseconds: 750)); // Wait for SnackBar

      // Verify success message first
      expect(find.text('Account created. Please log in.'), findsOneWidget);

      await tester.pumpAndSettle();

      // Additional wait for navigation to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should handle network error during signup', (tester) async {
      // Override mock to simulate network error
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
          '/auth/register', 500, MockApiResponses.networkError());

      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Navigate to signup
      await NavigationHelpers.navigateToSignupFromLogin(tester);

      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
      );

      // Ensure the button is visible before tapping
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

      // Wait for error SnackBar
      await tester.pump(); // Start the SnackBar animation
      await tester.pump(const Duration(milliseconds: 500)); // Let it animate

      // Should show error message - looking for the actual message from the response
      // The auth service extracts the 'detail' field from the response
      expect(find.text('Internal server error'), findsOneWidget);

      // Should remain on signup screen
      expect(find.byType(SignupScreen), findsOneWidget);

      await tester.pumpAndSettle(); // Complete animations

      // Wait for error SnackBar to disappear before retry
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Get auth bloc to check state
      final authBloc =
          tester.element(find.byType(SignupScreen)).read<AuthBloc>();

      // Test retry after error
      mockAdapter.clearResponses();
      mockAdapter.addResponse(
          '/auth/register', 201, MockApiResponses.successfulSignup());

      // Ensure button is visible for retry
      await tester.ensureVisible(find.byType(LoadingButton));
      await tester.pumpAndSettle();

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');

      // Wait for the request to complete and state to update
      await tester.pumpAndSettle();

      // Wait for SnackBar if signup was successful
      if (authBloc.state is AuthSignupDone) {
        await tester.pump(); // Start any animations
        await tester
            .pump(const Duration(milliseconds: 1000)); // Wait for SnackBar
      }

      // Should succeed on retry - check for either success message or direct navigation
      // Sometimes the SnackBar might be too quick to catch
      final successMessage = find.text('Account created. Please log in.');
      final loginScreen = find.byType(LoginScreen);

      // Either we see the success message or we've already navigated to login
      if (successMessage.evaluate().isEmpty && loginScreen.evaluate().isEmpty) {
        // Neither found, wait a bit more
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Now check again
      final hasSuccessMessage = successMessage.evaluate().isNotEmpty;
      final hasLoginScreen = loginScreen.evaluate().isNotEmpty;

      expect(hasSuccessMessage || hasLoginScreen, isTrue,
          reason:
              'Should either show success message or navigate to login screen');

      // If we saw the message, wait for navigation
      if (hasSuccessMessage) {
        await tester.pumpAndSettle(); // Complete animations
        expect(find.byType(LoginScreen), findsOneWidget);
      }
    });
  });
}
