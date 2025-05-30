import 'package:app/application/auth/auth_event.dart';
import 'package:app/domain/entity/login_entity.dart';
import 'package:app/domain/entity/signup_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures/auth_fixture.dart';

void main() {
  group('AuthEvent', () {
    group('SignupSubmitted', () {
      test('should support value equality', () {
        // Arrange
        final event1 = SignupSubmitted(
          signupData: AuthFixture.validSignupRequestEntity,
        );
        final event2 = SignupSubmitted(
          signupData: AuthFixture.validSignupRequestEntity,
        );

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        // Arrange
        final event = SignupSubmitted(
          signupData: AuthFixture.validSignupRequestEntity,
        );

        // Act & Assert
        expect(event.props, [AuthFixture.validSignupRequestEntity]);
      });

      test('should not be equal when signupData is different', () {
        // Arrange
        final event1 = SignupSubmitted(
          signupData: AuthFixture.validSignupRequestEntity,
        );
        final event2 = SignupSubmitted(
          signupData: SignupRequestEntity(
            phoneNumber: '+251987654321',
            password: 'differentPassword',
            name: 'Different Name',
            email: 'different@example.com',
          ),
        );

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });
    });

    group('LoginSubmitted', () {
      test('should support value equality', () {
        // Arrange
        final event1 = LoginSubmitted(
          loginData: AuthFixture.validLoginRequestEntity,
        );
        final event2 = LoginSubmitted(
          loginData: AuthFixture.validLoginRequestEntity,
        );

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        // Arrange
        final event = LoginSubmitted(
          loginData: AuthFixture.validLoginRequestEntity,
        );

        // Act & Assert
        expect(event.props, [AuthFixture.validLoginRequestEntity]);
      });

      test('should not be equal when loginData is different', () {
        // Arrange
        final event1 = LoginSubmitted(
          loginData: AuthFixture.validLoginRequestEntity,
        );
        final event2 = LoginSubmitted(
          loginData: LoginRequestEntity(
            phoneNumber: '+251987654321',
            password: 'differentPassword',
          ),
        );

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });
    });

    group('AppStarted', () {
      test('should support value equality', () {
        // Arrange
        final event1 = AppStarted();
        final event2 = AppStarted();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        // Arrange
        final event = AppStarted();

        // Act & Assert
        expect(event.props, isEmpty);
      });
    });

    group('LogoutRequested', () {
      test('should support value equality', () {
        // Arrange
        final event1 = LogoutRequested();
        final event2 = LogoutRequested();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        // Arrange
        final event = LogoutRequested();

        // Act & Assert
        expect(event.props, isEmpty);
      });
    });

    group('Event Type Verification', () {
      test('different event types should not be equal', () {
        // Arrange
        final appStarted = AppStarted();
        final logoutRequested = LogoutRequested();
        final signupSubmitted = SignupSubmitted(
          signupData: AuthFixture.validSignupRequestEntity,
        );
        final loginSubmitted = LoginSubmitted(
          loginData: AuthFixture.validLoginRequestEntity,
        );

        // Act & Assert
        expect(appStarted, isNot(equals(logoutRequested)));
        expect(appStarted, isNot(equals(signupSubmitted)));
        expect(appStarted, isNot(equals(loginSubmitted)));
        expect(logoutRequested, isNot(equals(signupSubmitted)));
        expect(logoutRequested, isNot(equals(loginSubmitted)));
        expect(signupSubmitted, isNot(equals(loginSubmitted)));
      });
    });
  });
}
