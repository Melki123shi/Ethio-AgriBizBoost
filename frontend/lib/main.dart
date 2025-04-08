import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/services/api/health_assessment_api.dart';
import 'package:app/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final healthService = HealthAssessmentService();
  
  runApp(
    BlocProvider(
    create: (context) => HealthAssessmentBloc(healthService),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, 
      theme: ThemeData( 
        brightness: Brightness.light,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        dividerColor: Colors.white,
        focusColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData( 
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        dividerColor: Colors.black,
        focusColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    ),
  ),
);
}
