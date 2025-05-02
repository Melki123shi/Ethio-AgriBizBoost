import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/forcasting/forcasting_output.dart';
import 'package:app/presentation/ui/health_assessment/health_assessmet_output.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/presentation/ui/profile/darkmode_screen.dart';
import 'package:app/presentation/ui/profile/edit_rofile_screen.dart';
import 'package:app/presentation/ui/profile/language_screen.dart';
import 'package:app/presentation/ui/profile/logout_screen.dart';
import 'package:app/presentation/ui/profile/notification_screen.dart';
import 'package:app/presentation/ui/profile/profile_screen.dart';
import 'package:app/presentation/ui/profile/security_screen.dart';
import 'package:app/presentation/ui/recommendation/loan_advice_mock_data.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SignupScreen(),
      routes: [
        GoRoute(
          path: 'signup',
          builder: (context, state) => SignupScreen(),
        ),
        GoRoute(
          path: 'login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: 'healthAssessmentOutput',
          builder: (context, state) {
            final result = state.extra
                as AssessmentResultEntity; 
            return HealthAssessmentOutput(result: result);
          },
        ),
        GoRoute(
          path: 'forcastingOutput',
          builder: (context, state) {
            final result = state.extra as ForcastingResultEntity;
            return ForcastingOutput(result: result);
          },
        ),
        GoRoute(
          path: 'loanAdvice',
          builder: (context, state) => const LoanAdviceMockData(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'editProfile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'security',
          builder: (context, state) => const SecurityScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: 'language',
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: 'darkmode',
          builder: (context, state) => const DarkmodeScreen(),
        ),
        GoRoute(
          path: 'logout',
          builder: (context, state) => const LogoutScreen(),
        ),
      ],
    ),
  ],
);
