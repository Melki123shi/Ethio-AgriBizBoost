import 'package:flutter/material.dart';

class NavigationTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  NavigationTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs = ['Health', 'Forecasting', 'Recommendation'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(tabs.length, (index) {
        bool isSelected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () {
              onTabSelected(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color.fromARGB(255, 97, 166, 45), Color.fromARGB(255, 0, 120, 32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFB0FF72), Color(0xFF7EFFA1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: Colors.greenAccent,
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

