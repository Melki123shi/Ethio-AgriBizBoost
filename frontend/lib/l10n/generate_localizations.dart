import 'dart:io';
import 'package:app/presentation/utils/case_converter_utils.dart';
import 'package:path/path.dart' as path;

const String commandToRunFlag = 'gen-l10n';
const String applicationResourceBundleDirectoryFlag = '--arb-dir=';
const String defaultLocalizationFileFlag = '--template-arb-file=';
const String outputLocalizationFileFlag = '--output-localization-file=';
const String outputClassNameFlag = '--output-class=';
const String outputDirectoryFlag = '--output-dir=';
const String nonSyntheticPackageFlag = '--no-synthetic-package';
const String localizationFileSuffix = '_localizations.dart';
const String templateFileSuffix = '_en.arb';
const String localizationsClassSuffix = 'Localizations';
const String localizationClassesDirectory = 'localization_classes';

List<String> buildCommandArgs({
  required String commandToRun,
  required String applicationResourceBundleDirectory,
  required String defaultLocalizationFile,
  required String outputLocalizationFileName,
  required String outputClassName,
  required String outputDirectory,
  required String syntheticPackage,
}) {
  return [
    commandToRun,
    '$applicationResourceBundleDirectoryFlag$applicationResourceBundleDirectory',
    '$defaultLocalizationFileFlag$defaultLocalizationFile',
    '$outputLocalizationFileFlag$outputLocalizationFileName',
    '$outputClassNameFlag$outputClassName',
    '$outputDirectoryFlag$outputDirectory',
    syntheticPackage,
  ];
}

Future<void> main() async {
  final rootDir = Directory.current;
  final appDir = Directory(path.join(rootDir.path, 'frontend'));
  final l10nDir = Directory(path.join(appDir.path, 'lib', 'l10n'));

  if (!await l10nDir.exists()) {
    return;
  }

  await for (var featureDir in l10nDir.list()) {
    if (featureDir is Directory) {
      final featureName = path.basename(featureDir.path);

      if (featureName.isEmpty) {
        continue;
      }

      final outputClassName =
          '${CaseConverter.toPascalCase(featureName)}$localizationsClassSuffix';
      final arbDir = featureDir.path;
      final templateArbFile = '$featureName$templateFileSuffix';
      final outputLocalizationFileName = '$featureName$localizationFileSuffix';
      final outputDir =
          path.join(featureDir.path, localizationClassesDirectory);
      final templateFilePath = File(path.join(arbDir, templateArbFile));

      if (!await templateFilePath.exists()) {
        continue;
      }

      final outputDirectory = Directory(outputDir);
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
      }

      final commandArgs = buildCommandArgs(
        commandToRun: commandToRunFlag,
        applicationResourceBundleDirectory: arbDir,
        defaultLocalizationFile: templateArbFile,
        outputLocalizationFileName: outputLocalizationFileName,
        outputClassName: outputClassName,
        outputDirectory: outputDir,
        syntheticPackage: nonSyntheticPackageFlag,
      );

      await Process.run('flutter', commandArgs,
          workingDirectory: appDir.path, runInShell: true);
    }
  }
}
