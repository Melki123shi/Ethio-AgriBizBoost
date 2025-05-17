import 'package:app/presentation/ui/navigation.dart';
import 'package:app/presentation/ui/recommendation/cost_cutting_strategies.dart';
import 'package:app/presentation/ui/recommendation/loan_advice_screen.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class RecommendationScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const RecommendationScreen({super.key, this.onSubmitted});

  @override
  RecommendationScreenState createState() => RecommendationScreenState();
}

class RecommendationScreenState extends State<RecommendationScreen> {
  int selectedIndex = 0;

  void onTabSelected(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.commonLocals.loan_advice,
      'cost cutting strategies',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationTabs(
            selectedIndex: selectedIndex,
            onTabSelected: onTabSelected,
            labels: labels,          
          ),
          const SizedBox(height: 25),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _currentTab(),
          ),
        ],
      ),
    );
  }

  Widget _currentTab() {
    switch (selectedIndex) {
      case 0:
        return LoanAdviceScreen(onSubmitted: widget.onSubmitted);
      case 1:
        return CostCuttingStrategiesScreen(onSubmitted: widget.onSubmitted);
      default:
        return const SizedBox.shrink();
    }
  }
}
