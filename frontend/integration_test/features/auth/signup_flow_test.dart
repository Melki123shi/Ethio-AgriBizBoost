import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_setup.dart';
import '../../helpers/mock_server.dart';
import '../../helpers/test_utils.dart';

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
    });

    tearDown(() async {
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
    });

    testWidgets('should complete signup with all fields successfully',
        (tester) async {
      // Arrange
      mockAdapter.addResponse(
          '/auth/register', 201, MockApiResponses.successfulSignup());

      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Act - Navigate to signup
      await TestUtils.tapButton(tester, 'Sign Up');
      await tester.pumpAndSettle();

      // Assert - Verify we're on signup screen
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsAtLeastNWidgets(1));

      // Act - Fill form with all fields
      await TestUtils.fillSignupForm(
        tester,
        name: 'Abebe Kebede',
        phoneNumber: '+251911234567',
        email: 'abebe.kebede@test.et',
        password: 'SecurePass123!',
      );

      // Act - Submit form
      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pumpAndSettle();

      // Assert - Verify success
      expect(find.text('Account created. Please log in.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);

      // Assert - Verify API call
      final signupRequest = mockAdapter.requests
          .where((r) => r.path == '/auth/register')
          .firstOrNull;

      expect(signupRequest, isNotNull);
      expect(signupRequest!.method, 'POST');
      expect(signupRequest.data, {
        'phone_number': '+251911234567',
        'name': 'Abebe Kebede',
        'email': 'abebe.kebede@test.et',
        'password': 'SecurePass123!',
      });
    });

    testWidgets('should complete signup with only required fields',
        (tester) async {
      // Arrange
      mockAdapter.addResponse(
          '/auth/register', 201, MockApiResponses.successfulSignup());

      await tester.pumpWidget(IntegrationTestApp.createApp());
      await tester.pumpAndSettle();

      // Act
      await TestUtils.tapButton(tester, 'Sign Up');
      await tester.pumpAndSettle();

      await TestUtils.fillSignupForm(
        tester,
        phoneNumber: '0911234567',
        password: 'Password123',
        // Omit optional fields
      );

      await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Account created. Please log in.'), findsOneWidget);

      final signupRequest = mockAdapter.requests.last;
      expect(signupRequest.data['phone_number'], '0911234567');
      expect(signupRequest.data['password'], 'Password123');
      // Name and email can be null or empty
    });

    group('Validation Tests', () {
      testWidgets('should validate empty form submission', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Submit empty form
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text('Please correct the highlighted fields.'),
            findsOneWidget);
      });

      testWidgets('should validate Ethiopian phone number formats',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test valid formats
        final validNumbers = [
          '+251911234567',
          '0911234567',
          '091 123 4567',
          '+251 91 123 4567',
        ];

        for (final number in validNumbers) {
          await TestUtils.fillSignupForm(
            tester,
            phoneNumber: number,
            password: 'ValidPass123',
          );

          await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
          await tester.pump();

          expect(
              find.text('Enter a valid Ethiopian phone number.'), findsNothing,
              reason: 'Should accept: $number');
        }

        // Test invalid formats
        final invalidNumbers = [
          '123456', // Too short
          '+1234567890', // Wrong country code
          '08123456789', // Wrong prefix
          '+25191234567', // Wrong format
          'abcdefghij', // Non-numeric
          '091234567890', // Too long
        ];

        for (final number in invalidNumbers) {
          await TestUtils.fillSignupForm(
            tester,
            phoneNumber: number,
            password: 'ValidPass123',
          );

          await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
          await tester.pump();

          expect(find.text('Enter a valid Ethiopian phone number.'),
              findsOneWidget,
              reason: 'Should reject: $number');
        }
      });

      testWidgets('should validate password requirements', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test password too short
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: '1234567', // 7 chars
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text('Password must be at least 8 characters.'),
            findsOneWidget);

        // Test minimum valid password
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: '12345678', // 8 chars
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(
            find.text('Password must be at least 8 characters.'), findsNothing);

        // Test password with special characters
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'P@ssw0rd!አበበ', // Special chars + Ethiopian
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(
            find.text('Password must be at least 8 characters.'), findsNothing);
      });

      testWidgets('should validate optional email field', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Empty email should be valid (optional)
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
          email: '',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text('Enter a valid email address.'), findsNothing);

        // Test invalid email formats
        final invalidEmails = [
          'invalid-email',
          '@domain.com',
          'user@',
          'user.domain.com',
          'user @domain.com',
          'user@domain',
        ];

        for (final email in invalidEmails) {
          await TestUtils.fillSignupForm(
            tester,
            phoneNumber: '0911234567',
            password: 'Password123',
            email: email,
          );

          await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
          await tester.pump();

          expect(find.text('Enter a valid email address.'), findsOneWidget,
              reason: 'Should reject: $email');
        }

        // Test valid email formats
        final validEmails = [
          'user@example.com',
          'test.user@domain.co.uk',
          'user+tag@example.org',
          'user123@test-domain.com',
          'አበበ@example.et', // Unicode in local part
        ];

        for (final email in validEmails) {
          await TestUtils.fillSignupForm(
            tester,
            phoneNumber: '0911234567',
            password: 'Password123',
            email: email,
          );

          await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
          await tester.pump();

          expect(find.text('Enter a valid email address.'), findsNothing,
              reason: 'Should accept: $email');
        }
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle duplicate phone number error', (tester) async {
        // Arrange
        mockAdapter.addResponse(
            '/auth/register',
            400,
            MockApiResponses.signupError(
                message: 'Phone number already registered'));

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Phone number already registered'), findsOneWidget);
        expect(find.byType(SignupScreen), findsOneWidget);
      });

      testWidgets('should handle network error and allow retry',
          (tester) async {
        // Arrange - First attempt fails
        mockAdapter.addResponse(
            '/auth/register', 500, {'detail': 'Internal server error'});

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Assert - Error shown
        expect(find.text('Internal server error'), findsOneWidget);

        // Arrange - Setup success for retry
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        // Act - Retry
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Assert - Success on retry
        expect(find.text('Account created. Please log in.'), findsOneWidget);
      });

      testWidgets('should handle validation error from server', (tester) async {
        // Arrange
        mockAdapter.addResponse('/auth/register', 422,
            MockApiResponses.validationError(message: 'Validation failed'));

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Validation failed'), findsOneWidget);
      });
    });

    group('UI State Tests', () {
      testWidgets('should show loading state during signup', (tester) async {
        // Arrange - Delayed response
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        // Submit and check loading state immediately
        await tester.tap(find.byType(LoadingButton));
        await tester.pump(); // Don't settle

        // Assert - Loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Button should be disabled
        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);

        // Complete the flow
        await tester.pumpAndSettle();
        expect(find.text('Account created. Please log in.'), findsOneWidget);
      });

      testWidgets('should handle Ethiopian characters in name field',
          (tester) async {
        // Arrange
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          name: 'አበበ ከበደ ወልደማሪያም',
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        // Assert - Name displays correctly
        expect(find.text('አበበ ከበደ ወልደማሪያም'), findsOneWidget);

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Verify API received Ethiopian characters correctly
        final request = mockAdapter.requests.last;
        expect(request.data['name'], 'አበበ ከበደ ወልደማሪያም');
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate to login after successful signup',
          (tester) async {
        // Arrange
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Account created. Please log in.'), findsOneWidget);
      });

      testWidgets('should navigate to login when tapping login link',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Act
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        expect(find.byType(SignupScreen), findsOneWidget);

        await TestUtils.tapButton(tester, 'Login');
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });
  });
}
