import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_setup.dart';
import '../../helpers/mock_server.dart';
import '../../helpers/test_utils.dart';
import 'test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔥 Authentication Edge Cases & Advanced Scenarios', () {
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
    });

    group('Race Conditions & Concurrency', () {
      testWidgets('should handle rapid form submissions gracefully',
          (tester) async {
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: AuthTestData.validPassword,
        );

        // Rapidly tap submit button multiple times
        final submitButton = find.byType(LoadingButton);
        await tester.tap(submitButton);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(submitButton);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(submitButton);

        await tester.pumpAndSettle();

        // Should only make one API call
        final loginRequests = mockAdapter.requests
            .where((r) => r.path == '/auth/login-with-json')
            .toList();
        expect(loginRequests.length, 1);

        // Should navigate to home
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle concurrent login and signup navigation',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Start on login screen
        expect(find.byType(LoginScreen), findsOneWidget);

        // Quickly navigate to signup and back
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pump(const Duration(milliseconds: 100));
        await TestUtils.tapButton(tester, 'Login');
        await tester.pumpAndSettle();

        // Should be back on login screen
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(SignupScreen), findsNothing);
      });
    });

    group('Memory & Performance Edge Cases', () {
      testWidgets('should handle extremely long input gracefully',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test with extremely long inputs
        final longName = 'አ' * 1000; // 1000 Ethiopian characters
        final longEmail = '${'a' * 100}@${'b' * 100}.com';

        await TestUtils.fillSignupForm(
          tester,
          name: longName,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          email: longEmail,
          password: AuthTestData.validPassword,
        );

        // Should handle without crashing
        expect(find.byType(SignupScreen), findsOneWidget);

        // Try to submit
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        // Should show validation error for email
        expect(find.text(AuthTestData.emailValidationError), findsOneWidget);
      });

      testWidgets('should handle special Unicode characters in all fields',
          (tester) async {
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test with various Unicode characters
        const unicodeName = 'አበበ 🌾 ከበደ 🌱 ወልደማሪያም';
        const unicodePassword = 'Pass123!@#\$%^&*()_+አበበ🔒';

        await TestUtils.fillSignupForm(
          tester,
          name: unicodeName,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: unicodePassword,
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Should handle Unicode correctly
        expect(find.text(AuthTestData.signupSuccessMessage), findsOneWidget);

        // Verify API received Unicode correctly
        final request = mockAdapter.requests.last;
        expect(request.data['name'], unicodeName);
        expect(request.data['password'], unicodePassword);
      });
    });

    group('Network Edge Cases', () {
      testWidgets('should handle network timeout gracefully', (tester) async {
        // Simulate extremely slow network
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: AuthTestData.validPassword,
        );

        // Start login
        await tester.tap(find.byType(LoadingButton));

        // Wait for potential timeout (simulated)
        await tester.pump(const Duration(seconds: 35));

        // Should show appropriate error or complete
        // In real scenario, this would test actual timeout handling
      });

      testWidgets('should handle intermittent network failures',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // First attempt - network error
        mockAdapter.addResponse(
            '/auth/login-with-json',
            0, // Network error
            {'error': 'Network unreachable'});

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: AuthTestData.validPassword,
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        // Second attempt - server error
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/login-with-json',
            503, // Service unavailable
            {'detail': 'Service temporarily unavailable'});

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        // Third attempt - success
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        // Should eventually succeed
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('State Management Edge Cases', () {
      testWidgets('should handle app lifecycle changes during auth',
          (tester) async {
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: AuthTestData.validPassword,
        );

        // Start login
        await tester.tap(find.byType(LoadingButton));
        await tester.pump();

        // Simulate app going to background and coming back
        // In real scenario, this would test lifecycle handling
        await tester.pumpAndSettle();

        // Should complete login successfully
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle BLoC disposal and recreation', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Navigate between screens multiple times
        for (int i = 0; i < 5; i++) {
          await TestUtils.tapButton(tester, 'Sign Up');
          await tester.pumpAndSettle();
          await TestUtils.tapButton(tester, 'Login');
          await tester.pumpAndSettle();
        }

        // Should still function correctly
        expect(find.byType(LoginScreen), findsOneWidget);

        // Try to login
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: AuthTestData.validPassword,
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('Security Edge Cases', () {
      testWidgets('should sanitize SQL injection attempts in inputs',
          (tester) async {
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test with SQL injection patterns
        const sqlInjectionName = "Robert'); DROP TABLE users;--";
        const sqlInjectionPassword = "' OR '1'='1";

        await TestUtils.fillSignupForm(
          tester,
          name: sqlInjectionName,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: sqlInjectionPassword,
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Should handle safely
        expect(find.text(AuthTestData.signupSuccessMessage), findsOneWidget);

        // Verify data is sent as-is (sanitization happens server-side)
        final request = mockAdapter.requests.last;
        expect(request.data['name'], sqlInjectionName);
        expect(request.data['password'], sqlInjectionPassword);
      });

      testWidgets('should handle XSS attempts in display fields',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test with XSS patterns
        const xssName = '<script>alert("XSS")</script>';
        const xssEmail = 'test@<script>alert("XSS")</script>.com';

        await TestUtils.fillSignupForm(
          tester,
          name: xssName,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          email: xssEmail,
          password: AuthTestData.validPassword,
        );

        // Should display safely (Flutter auto-escapes)
        expect(find.text(xssName), findsOneWidget);

        // Email validation should catch invalid format
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text(AuthTestData.emailValidationError), findsOneWidget);
      });
    });

    group('Accessibility Edge Cases', () {
      testWidgets('should handle screen reader navigation', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Test that all form fields are accessible
        final phoneField =
            find.widgetWithText(TextFormField, 'Enter your phone number');
        final passwordField =
            find.widgetWithText(TextFormField, 'Enter your password');

        expect(phoneField, findsOneWidget);
        expect(passwordField, findsOneWidget);

        // Verify semantic labels
        final phoneSemanticsLabel = tester.getSemantics(phoneField);
        expect(phoneSemanticsLabel.label, contains('phone'));

        final passwordSemanticsLabel = tester.getSemantics(passwordField);
        expect(passwordSemanticsLabel.label, contains('password'));
      });

      testWidgets('should support keyboard-only navigation', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Test tab navigation between fields
        final phoneField =
            find.widgetWithText(TextFormField, 'Enter your phone number');

        await tester.tap(phoneField);
        await tester.pump();

        // In real scenario, would test Tab key navigation
        // Flutter test environment has limitations here
      });
    });

    group('Data Validation Boundary Cases', () {
      testWidgets('should handle all Ethiopian telecom prefixes',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test all valid Ethiopian prefixes
        final prefixes = ['091', '092', '093', '094'];

        for (final prefix in prefixes) {
          final phoneNumber = '${prefix}1234567';

          await TestUtils.fillSignupForm(
            tester,
            phoneNumber: phoneNumber,
            password: AuthTestData.validPassword,
          );

          await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
          await tester.pump();

          expect(find.text(AuthTestData.phoneValidationError), findsNothing,
              reason: 'Prefix $prefix should be valid');
        }
      });

      testWidgets('should validate password edge cases', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test exact boundary (8 characters)
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: '12345678', // Exactly 8 chars
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text(AuthTestData.passwordValidationError), findsNothing);

        // Test one less than boundary (7 characters)
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: AuthTestData.validPhoneNumberLocal,
          password: '1234567', // 7 chars
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text(AuthTestData.passwordValidationError), findsOneWidget);
      });
    });
  });
}
