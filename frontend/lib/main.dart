import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/l10n/common/localization_classes/common_localizations.dart';
import 'package:app/l10n/om_material_localizations.dart';
import 'package:app/l10n/ti_material_localizations.dart';
import 'package:app/services/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/services/api/forcasting_service.dart';
import 'package:app/services/api/health_assessment_service.dart';
import 'package:app/presentation/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

void main() {
  final healthService = HealthAssessmentService();
  final forcastingService = ForcastingService();
  final authService = AuthService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HealthAssessmentBloc>(
          create: (context) => HealthAssessmentBloc(healthService),
        ),
        BlocProvider<ForcastingBloc>(
          create: (context) => ForcastingBloc(forcastingService),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService),
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
                  routerConfig: router,
                  themeMode: themeMode,
                  theme: ThemeData(
                    brightness: Brightness.light,
                    primaryColor: const Color.fromARGB(255, 132, 203, 133),
                    scaffoldBackgroundColor: Colors.white,
                    dividerColor: Colors.grey.shade300,
                    focusColor: Colors.black,
                    cardColor: const Color.fromARGB(255, 240, 240, 240),
                    splashColor: Colors.black12,
                    canvasColor: Colors.black26,
                    indicatorColor: const Color(0xFF94C495),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                  ),
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    primaryColor: const Color.fromARGB(255, 153, 215, 82),
                    scaffoldBackgroundColor: Colors.black,
                    dividerColor: Colors.white12,
                    focusColor: Colors.white,
                    cardColor: const Color(0xFF1E1E1E),
                    splashColor: Colors.white10,
                    canvasColor: Colors.white24,
                    indicatorColor: const Color.fromARGB(255, 64, 85, 64),
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
