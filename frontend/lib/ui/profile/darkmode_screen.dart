import 'package:flutter/material.dart';
import 'package:app/main.dart';

class DarkmodeScreen extends StatefulWidget {
  const DarkmodeScreen({super.key});

  @override
  State<DarkmodeScreen> createState() => _DarkmodeScreenState();
}

class _DarkmodeScreenState extends State<DarkmodeScreen> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    final currentMode = themeNotifier.value;
    _isDark = currentMode == ThemeMode.dark ||
              (currentMode == ThemeMode.system && WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDark = value;
      themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dark Mode')),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isDark ? 'Dark Mode is ON' : 'Dark Mode is OFF',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Switch(
              value: _isDark,
              onChanged: _toggleTheme,
            ),
          ],
        ),
      ),
    );
  }
}
