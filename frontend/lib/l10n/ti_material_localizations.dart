import 'package:flutter/material.dart';

class MaterialLocalizationsTi extends DefaultMaterialLocalizations {
  const MaterialLocalizationsTi();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _MaterialLocalizationsTiDelegate();

  @override
  String get okButtonLabel => 'እወ';

  @override
  String get cancelButtonLabel => 'ሰርዝ';

  @override
  String get closeButtonLabel => 'ዝጽእ';

  @override
  String get backButtonTooltip => 'ተመለስ';

  @override
  String get nextMonthTooltip => 'ወርሒ ቀጺሉ';

  @override
  String get previousMonthTooltip => 'ወርሒ ቀዳማይ';
}

class _MaterialLocalizationsTiDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsTiDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const MaterialLocalizationsTi();
  }

  @override
  bool shouldReload(_) => false;
}
