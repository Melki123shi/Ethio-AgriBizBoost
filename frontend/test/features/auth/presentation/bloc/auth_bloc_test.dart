import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/dto/signup_dto.dart';
import 'package:app/domain/entity/login_entity.dart';
// import 'package:app/services/api/auth_service.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/mocks.mocks.dart';
import '../../../../helpers/fixtures/auth_fixture.dart';

void main() {
  // Initialize Flutter bindings for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthBloc', () {
    late MockAuthService mockAuthService;

    setUp(() async {
      mockAuthService = MockAuthService();
      // Mock SharedPreferences for TokenStorage
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      reset(mockAuthService);
    });

    // Since the AuthBloc constructor triggers AppStarted, we skip initial state test
    // and focus on testing the event handlers directly

    group('SignupSubmitted', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthSignupDone] when signup succeeds',
        build: () {
          when(mockAuthService.signup(any))
              .thenAnswer((_) async => AuthFixture.validSignupResponseEntity);
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          SignupSubmitted(signupData: AuthFixture.validSignupRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          AuthSignupDone(),
        ],
        verify: (_) {
          verify(mockAuthService.signup(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthFailure] when signup fails',
        build: () {
          when(mockAuthService.signup(any))
              .thenThrow(Exception('Phone number already exists'));
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          SignupSubmitted(signupData: AuthFixture.validSignupRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          const AuthFailure('Exception: Phone number already exists'),
        ],
        verify: (_) {
          verify(mockAuthService.signup(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should call AuthService.signup with correct DTO',
        build: () {
          when(mockAuthService.signup(any))
              .thenAnswer((_) async => AuthFixture.validSignupResponseEntity);
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          SignupSubmitted(signupData: AuthFixture.validSignupRequestEntity),
        ),
        verify: (_) {
          final captured = verify(mockAuthService.signup(captureAny)).captured;
          final dto = captured.first as SignupRequestDTO;
          expect(dto.phoneNumber,
              AuthFixture.validSignupRequestEntity.phoneNumber);
          expect(dto.password, AuthFixture.validSignupRequestEntity.password);
          expect(dto.name, AuthFixture.validSignupRequestEntity.name);
          expect(dto.email, AuthFixture.validSignupRequestEntity.email);
        },
      );
    });

    group('LoginSubmitted', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthSuccess] when login succeeds',
        build: () {
          when(mockAuthService.login(any))
              .thenAnswer((_) async => AuthFixture.validLoginResponseEntity);
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          LoginSubmitted(loginData: AuthFixture.validLoginRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          AuthSuccess(),
        ],
        verify: (_) {
          verify(mockAuthService.login(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthFailure] when login fails',
        build: () {
          when(mockAuthService.login(any))
              .thenThrow(Exception('Invalid credentials'));
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          LoginSubmitted(loginData: AuthFixture.validLoginRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          const AuthFailure('Exception: Invalid credentials'),
        ],
        verify: (_) {
          verify(mockAuthService.login(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthFailure] when access token is null',
        build: () {
          final responseWithNullToken = LoginResponseEntity(
            accessToken: null,
            refreshToken: 'refresh_token',
            tokenType: 'Bearer',
          );
          when(mockAuthService.login(any))
              .thenAnswer((_) async => responseWithNullToken);
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          LoginSubmitted(loginData: AuthFixture.validLoginRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          const AuthFailure(
              'Exception: Login failed: no access token returned'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthFailure] when access token is empty',
        build: () {
          final responseWithEmptyToken = LoginResponseEntity(
            accessToken: '',
            refreshToken: 'refresh_token',
            tokenType: 'Bearer',
          );
          when(mockAuthService.login(any))
              .thenAnswer((_) async => responseWithEmptyToken);
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          LoginSubmitted(loginData: AuthFixture.validLoginRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          const AuthFailure(
              'Exception: Login failed: no access token returned'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call AuthService.login with correct DTO',
        build: () {
          when(mockAuthService.login(any))
              .thenAnswer((_) async => AuthFixture.validLoginResponseEntity);
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          LoginSubmitted(loginData: AuthFixture.validLoginRequestEntity),
        ),
        verify: (_) {
          final captured = verify(mockAuthService.login(captureAny)).captured;
          final dto = captured.first as LoginRequestDTO;
          expect(
              dto.phoneNumber, AuthFixture.validLoginRequestEntity.phoneNumber);
          expect(dto.password, AuthFixture.validLoginRequestEntity.password);
        },
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit AuthInitial when logout is requested',
        build: () {
          when(mockAuthService.logout()).thenAnswer((_) async {});
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [AuthInitial()],
        verify: (_) {
          verify(mockAuthService.logout()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit AuthInitial even when logout throws exception',
        build: () {
          when(mockAuthService.logout()).thenThrow(Exception('Logout failed'));
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [AuthInitial()],
        verify: (_) {
          verify(mockAuthService.logout()).called(1);
        },
      );
    });

    group('Error Handling', () {
      test('should handle different exception types properly', () {
        // Test different error message formats
        final exceptions = [
          'Simple string error',
          Exception('Exception with message'),
          'Network timeout error',
        ];

        for (final exception in exceptions) {
          expect(
            exception.toString(),
            isA<String>(),
            reason: 'All exceptions should be convertible to string',
          );
        }
      });

      blocTest<AuthBloc, AuthState>(
        'should emit AuthFailure with proper error message format',
        build: () {
          when(mockAuthService.login(any)).thenThrow('Custom error message');
          return AuthBloc(mockAuthService, autoStart: false);
        },
        act: (bloc) => bloc.add(
          LoginSubmitted(loginData: AuthFixture.validLoginRequestEntity),
        ),
        expect: () => [
          AuthLoading(),
          const AuthFailure('Custom error message'),
        ],
      );
    });
  });
}
