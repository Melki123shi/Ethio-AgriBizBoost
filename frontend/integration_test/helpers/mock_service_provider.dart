import 'package:app/services/api/auth_service.dart';
import 'package:app/services/api/user_service.dart';
import 'package:app/services/api/health_assessment_service.dart';
import 'package:app/services/api/forcasting_service.dart';
import 'package:app/services/api/loan_advice_service.dart';
import 'package:app/services/api/expense_tracking_service.dart';
import 'package:dio/dio.dart';
import 'test_dio_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock service provider that creates services with mocked Dio
class MockServiceProvider {
  static AuthService? _authService;
  static UserService? _userService;
  static HealthAssessmentService? _healthService;
  static ForcastingService? _forcastingService;
  static LoanAdviceService? _loanAdviceService;
  static ExpenseTrackingService? _expenseTrackingService;

  /// Create mocked auth service
  static AuthService getAuthService() {
    if (_authService == null) {
      // Create a custom auth service that uses our test Dio
      _authService = MockAuthService();
    }
    return _authService!;
  }

  /// Create mocked user service
  static UserService getUserService() {
    if (_userService == null) {
      _userService = MockUserService();
    }
    return _userService!;
  }

  /// Create mocked health assessment service
  static HealthAssessmentService getHealthService() {
    if (_healthService == null) {
      _healthService = MockHealthAssessmentService();
    }
    return _healthService!;
  }

  /// Create mocked forcasting service
  static ForcastingService getForcastingService() {
    if (_forcastingService == null) {
      _forcastingService = MockForcastingService();
    }
    return _forcastingService!;
  }

  /// Create mocked loan advice service
  static LoanAdviceService getLoanAdviceService() {
    if (_loanAdviceService == null) {
      _loanAdviceService = MockLoanAdviceService();
    }
    return _loanAdviceService!;
  }

  /// Create mocked expense tracking service
  static ExpenseTrackingService getExpenseTrackingService() {
    if (_expenseTrackingService == null) {
      _expenseTrackingService = MockExpenseTrackingService();
    }
    return _expenseTrackingService!;
  }

  /// Reset all services
  static void reset() {
    _authService = null;
    _userService = null;
    _healthService = null;
    _forcastingService = null;
    _loanAdviceService = null;
    _expenseTrackingService = null;
  }
}

// Mock service implementations that use test Dio
class MockAuthService extends AuthService {
  @override
  final Dio dio = TestDioFactory.getTestDio();

  @override
  Future<void> logout() async {
    // Call parent logout to ensure proper API call
    await super.logout();

    // Ensure tokens are properly cleared from mock SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ACCESS_TOKEN');
    await prefs.remove('REFRESH_TOKEN');
    await prefs.remove('TOKEN_TYPE');
  }
}

class MockUserService extends UserService {
  @override
  final Dio dio = TestDioFactory.getTestDio();
}

class MockHealthAssessmentService extends HealthAssessmentService {
  @override
  final Dio dio = TestDioFactory.getTestDio();
}

class MockForcastingService extends ForcastingService {
  @override
  final Dio dio = TestDioFactory.getTestDio();
}

class MockLoanAdviceService extends LoanAdviceService {
  @override
  final Dio dio = TestDioFactory.getTestDio();
}

class MockExpenseTrackingService extends ExpenseTrackingService {
  @override
  final Dio dio = TestDioFactory.getTestDio();
}
