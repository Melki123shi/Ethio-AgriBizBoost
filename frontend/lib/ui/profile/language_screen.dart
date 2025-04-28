import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: selectedLanguage,
          decoration: const InputDecoration(labelText: 'Select Language'),
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Amharic', child: Text('Amharic')),
            DropdownMenuItem(value: 'French', child: Text('French')),
            DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
          ],
          onChanged: (value) => setState(() => selectedLanguage = value ?? 'English'),
        ),
      ),
    );
  }
}
