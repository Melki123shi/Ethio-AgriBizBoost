import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/presentation/ui/profile/profile_screen.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/app_setup.dart';
import '../../helpers/mock_server.dart';
import '../../helpers/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔐 Authentication Integration Tests', () {
    late MockHttpClientAdapter mockAdapter;

    setUpAll(() {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Clear all data before each test to ensure isolation
      await IntegrationTestApp.clearAllData();

      // Setup mock HTTP adapter
      mockAdapter = MockHttpClientAdapter();
      DioClient.resetForTesting();
      DioClient.getDio().httpClientAdapter = mockAdapter;
    });

    tearDown(() async {
      // Clean up after each test
      mockAdapter.clearResponses();
      await IntegrationTestApp.clearAllData();
    });

    group('📝 Sign-Up Flow Tests', () {
      setUp(() {
        // Setup common API responses for signup tests
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());
      });

      testWidgets('should complete signup flow with all fields',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Navigate to signup screen
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Verify we're on signup screen
        expect(find.byType(SignupScreen), findsOneWidget);
        expect(find.text('Sign Up'), findsAtLeastNWidgets(1));

        // Fill signup form with all fields including optional ones
        await TestUtils.fillSignupForm(
          tester,
          name: 'Abebe Kebede',
          phoneNumber: '+251911234567',
          email: 'abebe.kebede@test.et',
          password: 'SecurePass123!',
        );

        // Submit form
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Account created. Please log in.'), findsOneWidget);

        // Verify navigation back to login
        expect(find.byType(LoginScreen), findsOneWidget);

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

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Fill only required fields (phone and password)
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
          // name and email are optional
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        expect(find.text('Account created. Please log in.'), findsOneWidget);

        // Verify optional fields were handled correctly in API call
        final signupRequest = mockAdapter.requests.last;
        expect(signupRequest.data['phone_number'], '0911234567');
        expect(signupRequest.data['password'], 'Password123');
        // Name and email can be null or empty based on DTO handling
      });

      testWidgets('should show validation errors for invalid inputs',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test empty form submission
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text('Please correct the highlighted fields.'),
            findsOneWidget);

        // Test invalid phone number
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '123456', // Too short
          password: 'ValidPass123',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(
            find.text('Enter a valid Ethiopian phone number.'), findsOneWidget);

        // Test short password
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: '1234567', // 7 chars - too short
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text('Password must be at least 8 characters.'),
            findsOneWidget);

        // Test invalid email format
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'ValidPass123',
          email: 'invalid-email',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(find.text('Enter a valid email address.'), findsOneWidget);
      });

      testWidgets('should handle duplicate phone number error', (tester) async {
        // Override mock response for this test
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/register',
            400,
            MockApiResponses.signupError(
                message: 'Phone number already registered'));

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Phone number already registered'), findsOneWidget);

        // Should remain on signup screen
        expect(find.byType(SignupScreen), findsOneWidget);
      });

      testWidgets('should handle Ethiopian phone number formats',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Test international format
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '+251911234567',
          password: 'Password123',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        // Should not show validation error
        expect(
            find.text('Enter a valid Ethiopian phone number.'), findsNothing);

        // Test local format
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(
            find.text('Enter a valid Ethiopian phone number.'), findsNothing);

        // Test with spaces (should be cleaned)
        await TestUtils.fillSignupForm(
          tester,
          phoneNumber: '091 123 4567',
          password: 'Password123',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Sign Up');
        await tester.pump();

        expect(
            find.text('Enter a valid Ethiopian phone number.'), findsNothing);
      });
    });

    group('🔑 Login Flow Tests', () {
      setUp(() {
        // Setup common API responses for login tests
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
      });

      testWidgets('should complete login flow successfully', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Verify we're on login screen
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Login'), findsAtLeastNWidgets(1));

        // Fill login form
        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        // Check loading state when submitting
        await tester.tap(find.byType(LoadingButton));
        await tester.pump(); // Don't settle to catch loading state

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

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

      testWidgets('should show validation errors for invalid credentials',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Test empty form submission
        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pump();

        expect(find.text('Please correct the highlighted fields.'),
            findsOneWidget);

        // Test invalid phone format
        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: 'invalid',
          password: 'Password123',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pump();

        expect(
            find.text('Enter a valid Ethiopian phone number.'), findsOneWidget);

        // Test short password
        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: '0911234567',
          password: 'short',
        );
        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pump();

        expect(find.text('Password must be at least 8 characters.'),
            findsOneWidget);
      });

      testWidgets('should handle incorrect credentials error', (tester) async {
        // Override mock response for this test
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/login-with-json', 401, MockApiResponses.loginError());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: '0911234567',
          password: 'WrongPassword',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Invalid credentials'), findsOneWidget);

        // Should remain on login screen
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('should handle network error during login', (tester) async {
        // Override mock to simulate network error
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/login-with-json', 500, MockApiResponses.networkError());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.fillLoginForm(
          tester,
          phoneNumber: '0911234567',
          password: 'Password123',
        );

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Internal server error'), findsOneWidget);

        // Test retry after error
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await TestUtils.tapLoadingButtonByLabel(tester, 'Login');
        await tester.pumpAndSettle();

        // Should succeed on retry
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('🚪 Logout Flow Tests', () {
      setUp(() async {
        // Setup authenticated state before logout tests
        await IntegrationTestApp.setAuthenticatedState();

        // Setup API responses
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
        mockAdapter.addResponse(
            '/auth/logout', 200, MockApiResponses.logoutSuccess());
      });

      testWidgets('should complete logout flow successfully', (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Should auto-login and be on home screen
        expect(find.byType(HomeScreen), findsOneWidget);

        // Navigate to profile
        await TestUtils.navigateToProfile(tester);
        expect(find.byType(ProfileScreen), findsOneWidget);

        // Find and tap logout option
        final logoutOption = find.text('Log out');
        expect(logoutOption, findsOneWidget);
        await tester.tap(logoutOption);
        await tester.pumpAndSettle();

        // Confirm logout in dialog/confirmation
        await TestUtils.tapLoadingButtonByLabel(tester, 'Log out');
        await tester.pumpAndSettle();

        // Should navigate back to login
        expect(find.byType(LoginScreen), findsOneWidget);

        // Verify tokens were cleared
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
      });

      testWidgets('should handle logout failure gracefully', (tester) async {
        // Override logout response to simulate failure
        mockAdapter.clearResponses();
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());
        mockAdapter
            .addResponse('/auth/logout', 500, {'detail': 'Logout failed'});

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.navigateToProfile(tester);

        final logoutOption = find.text('Log out');
        await tester.tap(logoutOption);
        await tester.pumpAndSettle();

        await TestUtils.tapLoadingButtonByLabel(tester, 'Log out');
        await tester.pumpAndSettle();

        // Even on API failure, should clear local session
        final accessToken = await TokenStorage.readAccessToken();
        expect(accessToken, isNull);

        // Should still navigate to login
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });

    group('🔄 Auto-Login & Session Persistence Tests', () {
      testWidgets('should auto-login with valid stored tokens', (tester) async {
        // Setup valid tokens
        await TokenStorage.saveAccessToken('valid-token');
        await TokenStorage.saveRefreshToken('valid-refresh');
        await TokenStorage.saveTokenType('Bearer');

        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Should bypass login and go to home
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });

      testWidgets('should handle expired token with refresh', (tester) async {
        // Setup tokens
        await TokenStorage.saveAccessToken('expired-token');
        await TokenStorage.saveRefreshToken('valid-refresh');
        await TokenStorage.saveTokenType('Bearer');

        // First call fails with 401, then refresh succeeds
        mockAdapter
            .addResponse('/auth/profile', 401, {'detail': 'Token expired'});
        mockAdapter.addResponse(
            '/auth/refresh', 200, MockApiResponses.refreshTokenSuccess());
        // Profile call succeeds after refresh
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Should still reach home after token refresh
        expect(find.byType(HomeScreen), findsOneWidget);

        // Verify new tokens were stored
        final newToken = await TokenStorage.readAccessToken();
        expect(newToken, 'new-mock-access-token-456');
      });

      testWidgets('should redirect to login when refresh fails',
          (tester) async {
        // Setup tokens
        await TokenStorage.saveAccessToken('expired-token');
        await TokenStorage.saveRefreshToken('invalid-refresh');
        await TokenStorage.saveTokenType('Bearer');

        // Both initial call and refresh fail
        mockAdapter
            .addResponse('/auth/profile', 401, {'detail': 'Token expired'});
        mockAdapter.addResponse(
            '/auth/refresh', 401, {'detail': 'Invalid refresh token'});

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Should redirect to login
        expect(find.byType(LoginScreen), findsOneWidget);

        // Tokens should be cleared
        final token = await TokenStorage.readAccessToken();
        expect(token, isNull);
      });
    });

    group('🔀 Navigation Integration Tests', () {
      testWidgets('should navigate between auth screens correctly',
          (tester) async {
        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        // Start on login
        expect(find.byType(LoginScreen), findsOneWidget);

        // Navigate to signup
        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();
        expect(find.byType(SignupScreen), findsOneWidget);

        // Navigate back to login
        await TestUtils.tapButton(tester, 'Login');
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('should prevent back navigation after login', (tester) async {
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

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

        // Should be on home
        expect(find.byType(HomeScreen), findsOneWidget);

        // Try to go back (simulate back button)
        final NavigatorState navigator = tester.state(find.byType(Navigator));
        expect(navigator.canPop(), isFalse);
      });
    });

    group('🎛️ BLoC State Management Tests', () {
      testWidgets('should handle auth state transitions correctly',
          (tester) async {
        mockAdapter.addResponse(
            '/auth/login-with-json', 200, MockApiResponses.successfulLogin());
        mockAdapter.addResponse(
            '/auth/profile', 200, MockApiResponses.userProfile());

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

        // Start login
        await tester.tap(find.byType(LoadingButton));
        await tester.pump();

        // Should transition to loading
        expect(authBloc.state, isA<AuthLoading>());

        await tester.pumpAndSettle();

        // Should transition to success
        expect(authBloc.state, isA<AuthSuccess>());
      });
    });

    group('🌍 Internationalization Tests', () {
      testWidgets('should handle Ethiopian names and characters',
          (tester) async {
        mockAdapter.addResponse(
            '/auth/register', 201, MockApiResponses.successfulSignup());

        await tester.pumpWidget(IntegrationTestApp.createApp());
        await tester.pumpAndSettle();

        await TestUtils.tapButton(tester, 'Sign Up');
        await tester.pumpAndSettle();

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

        // Verify API received the name correctly
        final request = mockAdapter.requests.last;
        expect(request.data['name'], 'አበበ ከበደ ወልደማሪያም');
      });
    });
  });
}
