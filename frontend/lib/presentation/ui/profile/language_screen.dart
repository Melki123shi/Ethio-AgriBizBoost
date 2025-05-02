import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'English';

  final List<String> languages = [
  'English',
  'Amharic',
  'Afan Oromo',
  'Tigrigna',
];

  final GlobalKey _fieldKey = GlobalKey();

  void _selectLanguage(BuildContext context) async {
  final RenderBox renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
  final Offset offset = renderBox.localToGlobal(Offset.zero);
  final Size size = renderBox.size;

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height,
      offset.dx + size.width,
      0,
    ),
    color: Theme.of(context).indicatorColor, 
    items: languages
        .map(
          (lang) => PopupMenuItem(
            value: lang,
            child: SizedBox(
              width: size.width,
              child: Text(
                lang,
                style: TextStyle(color: Theme.of(context).focusColor), 
              ),
            ),
          ),
        )
        .toList(),
  );

  if (selected != null) {
    setState(() {
      selectedLanguage = selected;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectLanguage(context),
              child: Container(
                key: _fieldKey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color.fromARGB(255, 148, 196, 149)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedLanguage,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 148, 196, 149)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
