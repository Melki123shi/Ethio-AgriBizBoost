import 'package:app/main.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String selectedLanguage;

  final GlobalKey _fieldKey = GlobalKey();

  @override
  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final currentLocale = localeNotifier.value.languageCode;

  final map = {
    'en': context.commonLocals.english,
    'am': context.commonLocals.amharic,
    'om': context.commonLocals.afan_oromo,
    'ti': context.commonLocals.tigrigna,
  };

  selectedLanguage = map[currentLocale] ?? context.commonLocals.english;
}


  void _selectLanguage(BuildContext context) async {
    final languages = [
      context.commonLocals.english,
      context.commonLocals.amharic,
      context.commonLocals.afan_oromo,
      context.commonLocals.tigrigna,
    ];

    final languageMap = {
      context.commonLocals.english: const Locale('en'),
      context.commonLocals.amharic: const Locale('am'),
      context.commonLocals.afan_oromo: const Locale('om'),
      context.commonLocals.tigrigna: const Locale('ti'),
    };

    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

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

      final newLocale = languageMap[selected];
      if (newLocale != null) {
        localeNotifier.value = newLocale;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.commonLocals.language)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.commonLocals.select_language,
              style: const TextStyle(
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
                    const Icon(Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 148, 196, 149)),
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
