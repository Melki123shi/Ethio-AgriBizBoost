import 'package:app/presentation/utils/localization_extension.dart';
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
        (currentMode == ThemeMode.system &&
            WidgetsBinding.instance.window.platformBrightness ==
                Brightness.dark);
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
      appBar: AppBar(title: Text(context.commonLocals.darkmode)),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isDark ? context.commonLocals.dark_mode_on : context.commonLocals.dark_mode_off,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: _isDark,
                onChanged: _toggleTheme,
                activeColor: const Color(0xFF388E3C),
                activeTrackColor: const Color(0xFF81C784),
                inactiveThumbColor: const Color.fromARGB(255, 121, 185, 122),
                inactiveTrackColor: const Color.fromARGB(255, 196, 255, 198),
              ),
            )
          ],
        ),
      ),
    );
  }
}
