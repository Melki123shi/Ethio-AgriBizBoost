import 'package:app/application/auth/auth_state.dart';
import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';
import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/domain/entity/loan_advice_result_entity.dart';
import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:app/presentation/ui/expense_tracking/expense_tracking_screen.dart';
import 'package:app/presentation/ui/forcasting/forcasting_output.dart';
import 'package:app/presentation/ui/health_assessment/health_assessmet_output.dart';
import 'package:app/presentation/ui/home_screen.dart';
import 'package:app/presentation/ui/profile/darkmode_screen.dart';
import 'package:app/presentation/ui/profile/edit_profile_screen.dart';
import 'package:app/presentation/ui/profile/language_screen.dart';
import 'package:app/presentation/ui/profile/logout_screen.dart';
import 'package:app/presentation/ui/profile/notification_screen.dart';
import 'package:app/presentation/ui/profile/profile_screen.dart';
import 'package:app/presentation/ui/profile/security_screen.dart';
import 'package:app/presentation/ui/recommendation/cost_cutting_strategies_output_screen.dart';
import 'package:app/presentation/ui/recommendation/cost_cutting_strategies_screen.dart';
import 'package:app/presentation/ui/recommendation/loan_advice_output_screen.dart';
import 'package:app/presentation/ui/recommendation/loan_advice_screen.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:app/presentation/ui/chatbot/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/application/auth/auth_bloc.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter(this._authBloc, this.loggedIn);

  final AuthBloc _authBloc;
  final bool loggedIn;

  late final GoRouter router = GoRouter(
    refreshListenable: RouterNotifier(_authBloc.stream),
    // initialLocation: loggedIn ? '/home' : '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = _authBloc.state is AuthSuccess;
      final loggingIn = state.uri.toString() == '/login';
      final signingUp = state.uri.toString() == '/signup';

      if (!loggedIn && !loggingIn && !signingUp) {
        return '/login';
      }
      if (loggedIn && (loggingIn || signingUp)) {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (_, __) => '/login',
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/healthAssessmentOutput',
        builder: (_, state) => HealthAssessmentOutput(
          result: state.extra as AssessmentResultEntity,
        ),
      ),
      GoRoute(
        path: '/forcastingOutput',
        builder: (_, state) => ForcastingOutput(
          result: state.extra as ForcastingResultEntity,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/editProfile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (_, __) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (_, __) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/darkmode',
        builder: (_, __) => const DarkmodeScreen(),
      ),
      GoRoute(
        path: '/logout',
        builder: (_, __) => const LogoutScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (_, __) => const ChatScreen(),
      ),
      GoRoute(
        path: '/loan_advice',
        builder: (_, __) => const LoanAdviceScreen(),
      ),
      GoRoute(
        path: '/cost_cutting_strategies',
        builder: (_, __) => const CostCuttingStrategiesScreen(),
      ),
      GoRoute(
        path: '/expense_tracking',
        builder: (_, __) => const ExpenseTrackingScreen(),
      ),
      GoRoute(
        path: '/loan_advice_result',
        builder: (_, state) => LoanAdviceResultScreen(
            result: state.extra as LoanAdviceResultEntity),
      ),
      GoRoute(
        path: '/cost_cutting_result',
        builder: (_, state) => CostCuttingStrategiesOutputScreen(
            recommendationData: state.extra as RecommendationData),
      ),
      GoRoute(
        path: '/forecast-output',
        builder: (context, state) {
          final ForcastingResultEntity result =
              state.extra as ForcastingResultEntity;
          return ForcastingOutput(result: result);
        },
      ),
    ],
  );
}
