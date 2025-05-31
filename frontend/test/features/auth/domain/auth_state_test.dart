import 'package:app/application/auth/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthState', () {
    group('AuthInitial', () {
      test('should support value equality', () {
        // Arrange
        final state1 = AuthInitial();
        final state2 = AuthInitial();

        // Act & Assert
        expect(state1, equals(state2));
      });

      test('should have empty props', () {
        // Arrange
        final state = AuthInitial();

        // Act & Assert
        expect(state.props, isEmpty);
      });
    });

    group('AuthLoading', () {
      test('should support value equality', () {
        // Arrange
        final state1 = AuthLoading();
        final state2 = AuthLoading();

        // Act & Assert
        expect(state1, equals(state2));
      });

      test('should have empty props', () {
        // Arrange
        final state = AuthLoading();

        // Act & Assert
        expect(state.props, isEmpty);
      });
    });

    group('AuthSuccess', () {
      test('should support value equality', () {
        // Arrange
        final state1 = AuthSuccess();
        final state2 = AuthSuccess();

        // Act & Assert
        expect(state1, equals(state2));
      });

      test('should have empty props', () {
        // Arrange
        final state = AuthSuccess();

        // Act & Assert
        expect(state.props, isEmpty);
      });
    });

    group('AuthSignupDone', () {
      test('should support value equality', () {
        // Arrange
        final state1 = AuthSignupDone();
        final state2 = AuthSignupDone();

        // Act & Assert
        expect(state1, equals(state2));
      });

      test('should have empty props', () {
        // Arrange
        final state = AuthSignupDone();

        // Act & Assert
        expect(state.props, isEmpty);
      });
    });

    group('AuthFailure', () {
      test('should support value equality', () {
        // Arrange
        const state1 = AuthFailure('Error message');
        const state2 = AuthFailure('Error message');

        // Act & Assert
        expect(state1, equals(state2));
      });

      test('should have correct props', () {
        // Arrange
        const errorMessage = 'Test error message';
        const state = AuthFailure(errorMessage);

        // Act & Assert
        expect(state.props, [errorMessage]);
        expect(state.errorMessage, equals(errorMessage));
      });

      test('should not be equal when error messages are different', () {
        // Arrange
        const state1 = AuthFailure('Error message 1');
        const state2 = AuthFailure('Error message 2');

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should handle empty error message', () {
        // Arrange
        const state = AuthFailure('');

        // Act & Assert
        expect(state.errorMessage, equals(''));
        expect(state.props, ['']);
      });

      test('should handle null-like error message', () {
        // Arrange
        const state = AuthFailure('null');

        // Act & Assert
        expect(state.errorMessage, equals('null'));
        expect(state.props, ['null']);
      });
    });

    group('State Type Verification', () {
      test('different state types should not be equal', () {
        // Arrange
        final authInitial = AuthInitial();
        final authLoading = AuthLoading();
        final authSuccess = AuthSuccess();
        final authSignupDone = AuthSignupDone();
        const authFailure = AuthFailure('Error');

        // Act & Assert
        expect(authInitial, isNot(equals(authLoading)));
        expect(authInitial, isNot(equals(authSuccess)));
        expect(authInitial, isNot(equals(authSignupDone)));
        expect(authInitial, isNot(equals(authFailure)));
        expect(authLoading, isNot(equals(authSuccess)));
        expect(authLoading, isNot(equals(authSignupDone)));
        expect(authLoading, isNot(equals(authFailure)));
        expect(authSuccess, isNot(equals(authSignupDone)));
        expect(authSuccess, isNot(equals(authFailure)));
        expect(authSignupDone, isNot(equals(authFailure)));
      });
    });

    group('State Transitions', () {
      test('should represent typical authentication flow states', () {
        // Test that states can represent a typical flow
        final states = [
          AuthInitial(),
          AuthLoading(),
          AuthSuccess(),
        ];

        // Verify each state is of correct type
        expect(states[0], isA<AuthInitial>());
        expect(states[1], isA<AuthLoading>());
        expect(states[2], isA<AuthSuccess>());
      });

      test('should represent signup flow states', () {
        // Test that states can represent a signup flow
        final states = [
          AuthInitial(),
          AuthLoading(),
          AuthSignupDone(),
        ];

        // Verify each state is of correct type
        expect(states[0], isA<AuthInitial>());
        expect(states[1], isA<AuthLoading>());
        expect(states[2], isA<AuthSignupDone>());
      });

      test('should represent error flow states', () {
        // Test that states can represent an error flow
        final states = [
          AuthInitial(),
          AuthLoading(),
          const AuthFailure('Network error'),
        ];

        // Verify each state is of correct type
        expect(states[0], isA<AuthInitial>());
        expect(states[1], isA<AuthLoading>());
        expect(states[2], isA<AuthFailure>());
        expect(
            (states[2] as AuthFailure).errorMessage, equals('Network error'));
      });
    });

    group('State Properties', () {
      test('should have consistent toString representations', () {
        // Arrange & Act
        final authInitial = AuthInitial().toString();
        final authLoading = AuthLoading().toString();
        final authSuccess = AuthSuccess().toString();
        final authSignupDone = AuthSignupDone().toString();
        const authFailure = AuthFailure('Test error');
        final authFailureString = authFailure.toString();

        // Assert
        expect(authInitial, contains('AuthInitial'));
        expect(authLoading, contains('AuthLoading'));
        expect(authSuccess, contains('AuthSuccess'));
        expect(authSignupDone, contains('AuthSignupDone'));
        expect(authFailureString, contains('AuthFailure'));
      });
    });
  });
}
