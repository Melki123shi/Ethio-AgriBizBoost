import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';
import 'package:app/presentation/utils/localization_extension.dart'; 
import 'package:flutter/material.dart';

class CostCuttingStrategiesOutputScreen extends StatelessWidget {
  final RecommendationData recommendationData;

  const CostCuttingStrategiesOutputScreen({super.key, required this.recommendationData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.commonLocals.cost_cutting_result_title), 
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [ 
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), 
                    ),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text(
                    context.commonLocals.recommendation_label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    recommendationData.recommendation,
                    style: TextStyle(fontSize: 18, color: Theme.of(context).focusColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
