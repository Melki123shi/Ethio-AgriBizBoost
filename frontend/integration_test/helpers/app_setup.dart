import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/expense_tracking/bloc/expense_tracking_bloc.dart';
import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/application/recent_assessment_results/recent_assessment_result_bloc.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_bloc.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/l10n/common/localization_classes/common_localizations.dart';
import 'package:app/l10n/om_material_localizations.dart';
import 'package:app/l10n/ti_material_localizations.dart';
import 'package:app/presentation/router/app_router.dart';
import 'package:app/services/api/auth_service.dart';
import 'package:app/services/api/expense_tracking_service.dart';
import 'package:app/services/api/forcasting_service.dart';
import 'package:app/services/api/health_assessment_service.dart';
import 'package:app/services/api/loan_advice_service.dart';
import 'package:app/services/api/user_service.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_server.dart';

class IntegrationTestApp {
  static Widget createApp({bool skipAuth = false}) {
    // Reset DioClient before creating services
    DioClient.resetForTesting();

    final healthService = HealthAssessmentService();
    final forcastingService = ForcastingService();
    final authService = AuthService();
    final userService = UserService();
    final loanAdviceService = LoanAdviceService();
    final expenseTrackingService = ExpenseTrackingService();
    final authBloc = AuthBloc(authService, autoStart: !skipAuth);
    final loggedIn = TokenStorage.readAccessToken() != '';
    final appRouter = AppRouter(authBloc, loggedIn).router;

    if (!skipAuth) {
      authBloc.add(AppStarted());
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<HealthAssessmentBloc>(
          create: (context) => HealthAssessmentBloc(healthService),
        ),
        BlocProvider<ForcastingBloc>(
          create: (context) => ForcastingBloc(forcastingService),
        ),
        BlocProvider.value(value: authBloc),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(userService),
        ),
        BlocProvider<LoanAdviceBloc>(
          create: (context) => LoanAdviceBloc(loanAdviceService),
        ),
        BlocProvider<ExpenseTrackingBloc>(
          create: (context) => ExpenseTrackingBloc(expenseTrackingService),
        ),
        BlocProvider<RecentAssessmentBloc>(
          create: (context) => RecentAssessmentBloc(healthService),
        ),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        supportedLocales: const [
          Locale('en'),
          Locale('am'),
          Locale('om'),
          Locale('ti'),
        ],
        localizationsDelegates: const [
          CommonLocalizations.delegate,
          MaterialLocalizationsTi.delegate,
          MaterialLocalizationsOm.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          textTheme: GoogleFonts.notoSansEthiopicTextTheme(),
          brightness: Brightness.light,
          primaryColor: const Color.fromARGB(255, 132, 203, 133),
          scaffoldBackgroundColor: Colors.white,
          dividerColor: Colors.grey.shade300,
          focusColor: Colors.black,
          cardColor: const Color.fromARGB(255, 240, 240, 240),
          splashColor: Colors.black12,
          canvasColor: Colors.black26,
          indicatorColor: const Color(0xFF94C495),
          hintColor: const Color.fromARGB(255, 201, 201, 201),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  /// Create app with mock adapter already set up
  static Widget createAppWithMockAdapter(
    MockHttpClientAdapter mockAdapter, {
    bool skipAuth = false,
  }) {
    // Reset DioClient and set mock adapter before creating services
    DioClient.resetForTesting();
    DioClient.getDio().httpClientAdapter = mockAdapter;

    return createApp(skipAuth: skipAuth);
  }

  /// Clean up all stored data before tests
  static Future<void> clearAllData() async {
    SharedPreferences.setMockInitialValues({});
    await TokenStorage.clearAccessToken();
    await TokenStorage.clearRefreshToken();
    await TokenStorage.clearTokenType();
  }

  /// Set up authenticated state for tests that need it
  static Future<void> setAuthenticatedState() async {
    await TokenStorage.saveAccessToken('mock_access_token');
    await TokenStorage.saveRefreshToken('mock_refresh_token');
    await TokenStorage.saveTokenType('Bearer');
  }
}
