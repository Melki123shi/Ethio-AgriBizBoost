import 'package:flutter/material.dart';

class DarkmodeScreen extends StatelessWidget {
  const DarkmodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Dark Mode')),
      body: Center(
        child: Text(
          isDark ? 'Dark Mode is ON' : 'Dark Mode is OFF',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
