import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_bloc.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/l10n/common/localization_classes/common_localizations.dart';
import 'package:app/l10n/om_material_localizations.dart';
import 'package:app/l10n/ti_material_localizations.dart';
import 'package:app/services/api/auth_service.dart';
import 'package:app/services/api/loan_advice_service.dart';
import 'package:app/services/api/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/services/api/forcasting_service.dart';
import 'package:app/services/api/health_assessment_service.dart';
import 'package:app/presentation/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

final themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

void main() {
  final healthService = HealthAssessmentService();
  final forcastingService = ForcastingService();
  final authService = AuthService();
  final userService = UserService();
  final loanAdviceService = LoanAdviceService();
  final authBloc = AuthBloc(authService)..add(AppStarted());
  final appRouter = AppRouter(authBloc).router;

  runApp(
    MultiBlocProvider(
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
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return ValueListenableBuilder<Locale>(
              valueListenable: localeNotifier,
              builder: (context, locale, _) {
                return MaterialApp.router(
                  locale: locale,
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
                  themeMode: themeMode,
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
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    primaryColor: const Color.fromARGB(255, 100, 163, 86),
                    scaffoldBackgroundColor: Colors.black,
                    dividerColor: Colors.white12,
                    focusColor: Colors.white,
                    cardColor: const Color(0xFF1E1E1E),
                    splashColor: Colors.white10,
                    canvasColor: Colors.white24,
                    indicatorColor: const Color.fromARGB(255, 64, 85, 64),
                    hintColor: const Color.fromARGB(255, 130, 130, 130),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                );
              });
        },
      ),
    ),
  );
}
