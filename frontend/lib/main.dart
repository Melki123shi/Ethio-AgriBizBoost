import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/services/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/services/api/forcasting_service.dart';
import 'package:app/services/api/health_assessment_service.dart';
import 'package:app/routes/app_router.dart';

final themeNotifier = ValueNotifier(ThemeMode.system);

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
          return MaterialApp.router(
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
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color.fromARGB(255, 153, 215, 82),
              // primaryColor: const Color.fromARGB(255, 148, 196, 149),
              scaffoldBackgroundColor: Colors.black,
              dividerColor: Colors.white12,
              focusColor: Colors.white,
              cardColor: const Color(0xFF1E1E1E),
              splashColor: Colors.white10,
              canvasColor: Colors.white24,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          );
        },
      ),
    ),
  );
}
