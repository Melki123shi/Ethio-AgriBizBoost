import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/ui/forcasting/forcasting_output.dart';
import 'package:app/ui/health_assessment/health_assessmet_output.dart';
import 'package:flutter/material.dart';
import 'package:app/ui/header.dart';
import 'package:app/ui/navigation.dart';
import 'package:app/ui/search_input.dart';
import 'package:app/ui/forcasting/forcasting_screen.dart';
import 'package:app/ui/health_assessment/health_assessment_screen.dart';
import 'package:app/ui/recommendation/recommnedation_screen.dart';
import 'package:app/ui/recommendation/loan_advice_mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  int selectedIndex = 0;

  void onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
      switch (index) {
        case 0:
          _navigatorKey.currentState?.pushNamed('/health');
          break;
        case 1:
          _navigatorKey.currentState?.pushNamed('/forecasting');
          break;
        case 2:
          _navigatorKey.currentState?.pushNamed('/recommendation');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(),
          const SizedBox(height: 25),
          const SearchInputField(),
          const SizedBox(height: 30),
          NavigationTabs(
            selectedIndex: selectedIndex,
            onTabSelected: onTabSelected,
          ),
          const SizedBox(height: 25),
          Expanded(
            child: Navigator(
              key: _navigatorKey,
              initialRoute: '/health',
              onGenerateRoute: (RouteSettings settings) {
                switch (settings.name) {
                  case '/health':
                    return MaterialPageRoute(builder: (_) => const HealthAssessmentScreen());
                  case '/forecasting':
                    return MaterialPageRoute(builder: (_) => const ForcastingScreen());
                  case '/recommendation':
                    return MaterialPageRoute(builder: (_) => const RecommnedationScreen());
                  case '/loanAdvice':
                    return MaterialPageRoute(builder: (_) => const LoanAdviceMockData());
                  case '/healthAssessmentOutput':
                  final result = settings.arguments as AssessmentResultEntity; 
                    return MaterialPageRoute(builder: (_) => HealthAssessmentOutput(result: result));
                  case '/forcastingOutput':
                    return MaterialPageRoute(builder: (_) => const ForcastingOutput());
                  default:
                    return MaterialPageRoute(builder: (_) => const HealthAssessmentScreen());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
