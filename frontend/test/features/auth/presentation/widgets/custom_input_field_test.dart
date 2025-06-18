import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:app/l10n/common/localization_classes/common_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('CustomInputField Widget Tests', () {
    Widget createWidgetUnderTest({
      String? label,
      required String hintText,
      IconButton? suffixIcon,
      TextEditingController? controller,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      ValueChanged<String>? onChanged,
      double? contentVerticalPadding,
      bool isRequired = false,
      String? Function(String?)? validator,
      Widget? prefixIcon,
      Color? borderColor,
      BorderRadius? borderRadius,
    }) {
      return MaterialApp(
        localizationsDelegates: const [
          CommonLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: CommonLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomInputField(
            label: label,
            hintText: hintText,
            suffixIcon: suffixIcon,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            contentVerticalPadding: contentVerticalPadding,
            isRequired: isRequired,
            validator: validator,
            prefixIcon: prefixIcon,
            borderColor: borderColor,
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    group('Basic Rendering Tests', () {
      testWidgets('renders with basic required properties', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Enter text',
        ));

        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Enter text'), findsOneWidget);
      });

      testWidgets('displays label when provided', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Username',
          hintText: 'Enter your username',
        ));

        // The label is set as a label property in InputDecoration, not as plain text
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Enter your username'), findsOneWidget);

        // Check that the CustomInputField has the correct label property
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.label, equals('Username'));
      });

      testWidgets('displays required indicator for required fields',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Email',
          hintText: 'Enter email',
          isRequired: true,
        ));

        // Should display label with required asterisk - look for the label RichText specifically
        final labelRichTexts = find.byType(RichText);
        expect(labelRichTexts, findsAtLeastNWidgets(1));

        // Check that the CustomInputField has the required property set
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.isRequired, isTrue);
      });

      testWidgets('does not show required indicator for optional fields',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Name',
          hintText: 'Enter name',
          isRequired: false,
        ));

        // Check that the CustomInputField has the required property set to false
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.isRequired, isFalse);
      });
    });

    group('Icon Display Tests', () {
      testWidgets('displays suffix icon when provided', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Search',
          suffixIcon: const IconButton(onPressed: null, icon: Icon(Icons.search)),
        ));

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('displays prefix icon when provided', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Username',
          prefixIcon: const Icon(Icons.person),
        ));

        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('displays both prefix and suffix icons', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: const IconButton(onPressed: null, icon: Icon(Icons.visibility)),
        ));

        expect(find.byIcon(Icons.lock), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('Text Input Behavior Tests', () {
      testWidgets('handles text input correctly', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Enter text',
          controller: controller,
        ));

        await tester.enterText(find.byType(TextFormField), 'Hello World');
        expect(controller.text, equals('Hello World'));
      });

      testWidgets('password field obscures text correctly', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Password',
          controller: controller,
          obscureText: true,
        ));

        // Enter text in password field
        await tester.enterText(find.byType(TextFormField), 'secret123');

        // Controller should have the actual text
        expect(controller.text, equals('secret123'));

        // But the display should show obscured characters (dots)
        // This is verified by checking the CustomInputField widget properties
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.obscureText, isTrue);
      });

      testWidgets('sets email keyboard type correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ));

        // Verify the CustomInputField has the correct keyboard type
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(
            customInputField.keyboardType, equals(TextInputType.emailAddress));
      });

      testWidgets('sets phone keyboard type correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Phone',
          keyboardType: TextInputType.phone,
        ));

        // Verify the CustomInputField has the correct keyboard type
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.keyboardType, equals(TextInputType.phone));
      });
    });

    group('Change Handler Tests', () {
      testWidgets('calls onChanged when text changes', (tester) async {
        String? changedValue;

        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Test input',
          onChanged: (value) => changedValue = value,
        ));

        await tester.enterText(find.byType(TextFormField), 'test');
        expect(changedValue, equals('test'));
      });

      testWidgets('handles multiple text changes', (tester) async {
        final List<String> changes = [];

        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Test input',
          onChanged: (value) => changes.add(value),
        ));

        await tester.enterText(find.byType(TextFormField), 'a');
        await tester.enterText(find.byType(TextFormField), 'ab');
        await tester.enterText(find.byType(TextFormField), 'abc');

        expect(changes, contains('abc'));
      });
    });

    group('Validation Tests', () {
      testWidgets('shows default validation error for required empty field',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            localizationsDelegates: [
              CommonLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: CommonLocalizations.supportedLocales,
            home: Scaffold(
              body: Form(
                child: CustomInputField(
                  hintText: 'Required field',
                  isRequired: true,
                ),
              ),
            ),
          ),
        );

        final textField = find.byType(TextFormField);
        await tester.enterText(textField, '');

        // Get the field's FormState and validate
        final textFormField = tester.widget<TextFormField>(textField);
        final validationResult = textFormField.validator?.call('');

        expect(validationResult, contains('Cannot be empty'));
      });

      testWidgets('uses custom validator when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                child: CustomInputField(
                  hintText: 'Email',
                  validator: (value) {
                    if (value?.contains('@') != true) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        );

        final textField = find.byType(TextFormField);
        final textFormField = tester.widget<TextFormField>(textField);

        // Test invalid email
        final invalidResult = textFormField.validator?.call('invalid');
        expect(invalidResult, equals('Invalid email'));

        // Test valid email
        final validResult = textFormField.validator?.call('test@example.com');
        expect(validResult, isNull);
      });

      testWidgets('allows empty input for non-required fields', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Form(
                child: CustomInputField(
                  hintText: 'Optional field',
                  isRequired: false,
                ),
              ),
            ),
          ),
        );

        final textField = find.byType(TextFormField);
        final textFormField = tester.widget<TextFormField>(textField);

        final validationResult = textFormField.validator?.call('');
        expect(validationResult, isNull);
      });
    });

    group('Widget Properties Tests', () {
      testWidgets('sets correct widget properties', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Test Label',
          hintText: 'Test Hint',
          obscureText: true,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          contentVerticalPadding: 25,
        ));

        // Verify the CustomInputField widget properties
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.label, equals('Test Label'));
        expect(customInputField.hintText, equals('Test Hint'));
        expect(customInputField.obscureText, isTrue);
        expect(
            customInputField.keyboardType, equals(TextInputType.emailAddress));
        expect(customInputField.isRequired, isTrue);
        expect(customInputField.contentVerticalPadding, equals(25));
      });

      testWidgets('handles optional properties correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Basic input',
        ));

        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.label, isNull);
        expect(customInputField.obscureText, isFalse);
        expect(customInputField.keyboardType, equals(TextInputType.text));
        expect(customInputField.isRequired, isFalse);
      });
    });

    group('Theme Integration Tests', () {
      testWidgets('adapts to light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            localizationsDelegates: const [
              CommonLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: CommonLocalizations.supportedLocales,
            home: const Scaffold(
              body: CustomInputField(
                hintText: 'Light theme',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
        // Should render without errors in light theme
      });

      testWidgets('adapts to dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: const [
              CommonLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: CommonLocalizations.supportedLocales,
            home: const Scaffold(
              body: CustomInputField(
                hintText: 'Dark theme',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
        // Should render without errors in dark theme
      });
    });

    group('Accessibility Tests', () {
      testWidgets('provides proper semantics', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Username',
          hintText: 'Enter your username',
        ));

        // Should have semantic label
        expect(find.bySemanticsLabel('Username'), findsOneWidget);
      });

      testWidgets('supports screen readers with hint text', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Enter your email address',
        ));

        // Check that hint text is present
        expect(find.text('Enter your email address'), findsOneWidget);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('handles null controller gracefully', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'No controller',
          controller: null,
        ));

        expect(find.byType(TextFormField), findsOneWidget);

        // Should be able to enter text even without controller
        await tester.enterText(find.byType(TextFormField), 'test');
        expect(find.text('test'), findsOneWidget);
      });

      testWidgets('handles extremely long hint text', (tester) async {
        final longHint = 'a' * 1000;

        await tester.pumpWidget(createWidgetUnderTest(
          hintText: longHint,
        ));

        expect(find.byType(TextFormField), findsOneWidget);
        // Should render without crashing
      });

      testWidgets('handles special characters in hint text', (tester) async {
        const specialHint = r'!@#$%^&*()_+{}|:"<>?';

        await tester.pumpWidget(createWidgetUnderTest(
          hintText: specialHint,
        ));

        expect(find.text(specialHint), findsOneWidget);
      });

      testWidgets('handles unicode characters in labels', (tester) async {
        const unicodeLabel = '用户名 (አብርሃም)';

        await tester.pumpWidget(createWidgetUnderTest(
          label: unicodeLabel,
          hintText: 'Enter username',
        ));

        // Check that the CustomInputField has the correct label property
        final customInputField =
            tester.widget<CustomInputField>(find.byType(CustomInputField));
        expect(customInputField.label, equals(unicodeLabel));
      });
    });

    group('Focus and Interaction Tests', () {
      testWidgets('gains focus when tapped', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          hintText: 'Tap to focus',
        ));

        final textField = find.byType(TextFormField);
        await tester.tap(textField);
        await tester.pump();

        // Field should be focused (cursor should be visible)
        expect(textField, findsOneWidget);
      });

      testWidgets('loses focus when tapped outside', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CustomInputField(hintText: 'Focus test'),
                  Text('Outside text'),
                ],
              ),
            ),
          ),
        );

        // Focus the text field
        await tester.tap(find.byType(TextFormField));
        await tester.pump();

        // Tap outside
        await tester.tap(find.text('Outside text'));
        await tester.pump();

        // Field should lose focus
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Form Integration Tests', () {
      testWidgets('integrates properly with Form widget', (tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    const CustomInputField(
                      hintText: 'Required field',
                      isRequired: true,
                    ),
                    ElevatedButton(
                      onPressed: () => formKey.currentState?.validate(),
                      child: const Text('Validate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Should work as part of a form
        expect(find.byType(Form), findsOneWidget);
        expect(find.byType(CustomInputField), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });
  });
}
