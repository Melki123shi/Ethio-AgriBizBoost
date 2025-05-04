import 'package:flutter/material.dart';

class MaterialLocalizationsOm extends DefaultMaterialLocalizations {
  const MaterialLocalizationsOm();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _MaterialLocalizationsOmDelegate();

  @override
  String get okButtonLabel => 'Tole';

  @override
  String get cancelButtonLabel => 'Haqi';

  @override
  String get closeButtonLabel => 'Cufi';

  @override
  String get backButtonTooltip => 'Deebi\'i';

  @override
  String get nextMonthTooltip => 'Ji’a itti aanu';

  @override
  String get previousMonthTooltip => 'Ji’a darbe';
}

class _MaterialLocalizationsOmDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsOmDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const MaterialLocalizationsOm();
  }

  @override
  bool shouldReload(_) => false;
}
