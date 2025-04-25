import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/services/api/forcasting_api.dart';
import 'package:app/services/api/health_assessment_api.dart';
import 'package:app/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final healthService = HealthAssessmentService();
  final forcastingService = ForcastingService();

  runApp(
    MultiBlocProvider(
        providers: [
          BlocProvider<HealthAssessmentBloc>(
            create: (context) => HealthAssessmentBloc(healthService),
          ),
          BlocProvider<ForcastingBloc>(
            create: (context) => ForcastingBloc(forcastingService),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF8BC34A), // green header
            scaffoldBackgroundColor: Colors.white,
            dividerColor: Colors.grey.shade300,
            focusColor: Colors.black,
            cardColor: const Color(0xFFF0F0F0), // light mode settings tile bg
            splashColor: Colors.black12,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF8BC34A), // same green header
            scaffoldBackgroundColor: Colors.black,
            dividerColor: Colors.white12,
            focusColor: Colors.white,
            cardColor: const Color(0xFF1E1E1E), // dark mode settings tile bg
            splashColor: Colors.white10,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: const HomeScreen(),
        )
        ),
  );
}
