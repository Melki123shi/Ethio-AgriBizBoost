import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/ui/forcasting/forcasting_output.dart';
import 'package:app/ui/health_assessment/health_assessmet_output.dart';
import 'package:app/ui/home_screen.dart';
import 'package:app/ui/profile/darkmode_screen.dart';
import 'package:app/ui/profile/edit_rofile_screen.dart';
import 'package:app/ui/profile/language_screen.dart';
import 'package:app/ui/profile/logout_screen.dart';
import 'package:app/ui/profile/notification_screen.dart';
import 'package:app/ui/profile/profile_screen.dart';
import 'package:app/ui/profile/security_screen.dart';
import 'package:app/ui/recommendation/loan_advice_mock_data.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
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
