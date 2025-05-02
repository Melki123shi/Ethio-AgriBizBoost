import 'package:app/l10n/common/localization_classes/common_localizations.dart';
import 'package:flutter/material.dart';

extension LocalisationExtension on BuildContext {
  CommonLocalizations get commonLocals => CommonLocalizations.of(this)!;

}
