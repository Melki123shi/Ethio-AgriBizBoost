import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/presentation/ui/forcasting/forcasting_output.dart';
import 'package:app/presentation/ui/health_assessment/health_assessmet_output.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/ui/profile/header.dart';
import 'package:app/presentation/ui/navigation.dart';
import 'package:app/presentation/ui/search_input.dart';
import 'package:app/presentation/ui/forcasting/forcasting_screen.dart';
import 'package:app/presentation/ui/health_assessment/health_assessment_screen.dart';
import 'package:app/presentation/ui/recommendation/recommnedation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  AssessmentResultEntity? _healthResult;
  ForcastingResultEntity? _forecastResult;

  void onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
      _healthResult = null;
      _forecastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(),
          // const SearchInputField(),
          const SizedBox(height: 30),
          NavigationTabs(
            selectedIndex: selectedIndex,
            onTabSelected: onTabSelected,
          ),
          const SizedBox(height: 25),
          Expanded(
            child: SafeArea(
              child: _buildCurrentTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (selectedIndex == 0) {
      if (_healthResult != null) {
        return HealthAssessmentOutput(result: _healthResult!);
      }
      return HealthAssessmentScreen(
        onSubmitted: (result) {
          setState(() {
            _healthResult = result;
          });
        },
      );
    } else if (selectedIndex == 1) {
      if (_forecastResult != null) {
        return ForcastingOutput(result: _forecastResult!);
      }
      return ForcastingScreen(
        onSubmitted: (result) {
          setState(() {
            _forecastResult = result;
          });
        },
      );
    } else if (selectedIndex == 2) {
      return RecommnedationScreen(
        onSubmitted: () {
          setState(() {});
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
