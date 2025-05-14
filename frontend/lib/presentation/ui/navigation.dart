import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class NavigationTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String>? labels;

  const NavigationTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = labels ??
        [
          context.commonLocals.health,
          context.commonLocals.forcasting,
          context.commonLocals.recommendation,
        ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(tabs.length, (index) {
        final isSelected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 115, 155, 85),
                          Color.fromARGB(255, 87, 187, 114),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 142, 196, 101),
                          Color(0xFF7EFFA1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: const Color.fromARGB(255, 140, 190, 166),
                  width: 1.5,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                  decoration: isSelected ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
