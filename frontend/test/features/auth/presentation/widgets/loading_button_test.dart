import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/l10n/common/localization_classes/common_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('LoadingButton Widget Tests', () {
    Widget createWidgetUnderTest({
      required String label,
      required bool loading,
      VoidCallback? onPressed,
      double width = 140,
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
          body: LoadingButton(
            label: label,
            loading: loading,
            onPressed: onPressed,
            width: width,
          ),
        ),
      );
    }

    group('Basic Rendering Tests', () {
      testWidgets('renders with basic required properties', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit',
          loading: false,
        ));

        expect(find.byType(LoadingButton), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Submit'), findsOneWidget);
      });

      testWidgets('displays label text correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Sign Up',
          loading: false,
        ));

        expect(find.text('Sign Up'), findsOneWidget);
      });

      testWidgets('applies correct default width', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Login',
          loading: false,
        ));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(140));
      });

      testWidgets('applies custom width when provided', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Login',
          loading: false,
          width: 200,
        ));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(200));
      });
    });

    group('Loading State Tests', () {
      testWidgets('displays loading indicator when loading is true',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit',
          loading: true,
        ));

        // Should show CircularProgressIndicator instead of text
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Submit'), findsNothing);
      });

      testWidgets('displays text when loading is false', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit',
          loading: false,
        ));

        // Should show text instead of loading indicator
        expect(find.text('Submit'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('disables button when loading is true', (tester) async {
        bool buttonPressed = false;

        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit',
          loading: true,
          onPressed: () => buttonPressed = true,
        ));

        final elevatedButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(elevatedButton.onPressed, isNull);

        // Try to tap the button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Button should not have been pressed
        expect(buttonPressed, isFalse);
      });

      testWidgets('enables button when loading is false', (tester) async {
        bool buttonPressed = false;

        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit',
          loading: false,
          onPressed: () => buttonPressed = true,
        ));

        final elevatedButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(elevatedButton.onPressed, isNotNull);

        // Tap the button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Button should have been pressed
        expect(buttonPressed, isTrue);
      });
    });

    group('Interaction Tests', () {
      testWidgets('calls onPressed when tapped and not loading',
          (tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Click Me',
          loading: false,
          onPressed: () => wasPressed = true,
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });

      testWidgets('does not call onPressed when loading', (tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Click Me',
          loading: true,
          onPressed: () => wasPressed = true,
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isFalse);
      });

      testWidgets('handles null onPressed callback', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Disabled',
          loading: false,
          onPressed: null,
        ));

        final elevatedButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(elevatedButton.onPressed, isNull);

        // Should not crash when tapped
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
      });

      testWidgets('handles multiple rapid taps correctly', (tester) async {
        int pressCount = 0;

        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Multi Tap',
          loading: false,
          onPressed: () => pressCount++,
        ));

        // Rapid taps
        await tester.tap(find.byType(ElevatedButton));
        await tester.tap(find.byType(ElevatedButton));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(pressCount, equals(3));
      });
    });

    group('Loading Indicator Properties Tests', () {
      testWidgets('loading indicator has correct size', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Loading',
          loading: true,
        ));

        final progressIndicator = find.byType(SizedBox).last;
        final sizedBox = tester.widget<SizedBox>(progressIndicator);

        expect(sizedBox.height, equals(16));
        expect(sizedBox.width, equals(16));
      });

      testWidgets('loading indicator has correct stroke width', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Loading',
          loading: true,
        ));

        final progressIndicator = tester.widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator));

        expect(progressIndicator.strokeWidth, equals(2));
      });
    });

    group('Styling Tests', () {
      testWidgets('applies correct button styling', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Styled Button',
          loading: false,
        ));

        final elevatedButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final buttonStyle = elevatedButton.style!;

        // Check padding - vertical: 12 means top: 12, bottom: 12 = 24 total height
        final padding = buttonStyle.padding?.resolve({}) as EdgeInsets?;
        expect(padding?.vertical, equals(24.0)); // 12 top + 12 bottom = 24

        // Check shape
        final shape = buttonStyle.shape?.resolve({}) as RoundedRectangleBorder?;
        expect(shape?.borderRadius, equals(BorderRadius.circular(30)));
      });

      testWidgets('text has correct styling', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Text Style',
          loading: false,
        ));

        final text = tester.widget<Text>(find.text('Text Style'));
        expect(text.style?.fontSize, equals(16));
      });
    });

    group('Theme Integration Tests', () {
      testWidgets('adapts to light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            localizationsDelegates: [
              CommonLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: CommonLocalizations.supportedLocales,
            home: Scaffold(
              body: LoadingButton(
                label: 'Light Theme',
                loading: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(LoadingButton), findsOneWidget);
        expect(find.text('Light Theme'), findsOneWidget);
      });

      testWidgets('adapts to dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: [
              CommonLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: CommonLocalizations.supportedLocales,
            home: Scaffold(
              body: LoadingButton(
                label: 'Dark Theme',
                loading: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(LoadingButton), findsOneWidget);
        expect(find.text('Dark Theme'), findsOneWidget);
      });

      testWidgets('uses theme colors correctly', (tester) async {
        final customTheme = ThemeData(
          primaryColor: Colors.red,
          focusColor: Colors.blue,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: customTheme,
            localizationsDelegates: [
              CommonLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: CommonLocalizations.supportedLocales,
            home: Scaffold(
              body: LoadingButton(
                label: 'Custom Colors',
                loading: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Should render without errors with custom theme
        expect(find.byType(LoadingButton), findsOneWidget);
      });
    });

    group('State Transition Tests', () {
      testWidgets('transitions from normal to loading state', (tester) async {
        bool isLoading = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      LoadingButton(
                        label: 'Submit',
                        loading: isLoading,
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // Initially should show text
        expect(find.text('Submit'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Tap to start loading
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Should now show loading indicator
        expect(find.text('Submit'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Reset to normal state
        await tester.tap(find.text('Reset'));
        await tester.pump();

        // Should show text again
        expect(find.text('Submit'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Widget Properties Tests', () {
      testWidgets('sets correct widget properties', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Test Label',
          loading: true,
          width: 250,
        ));

        // Verify the LoadingButton widget properties
        final loadingButton =
            tester.widget<LoadingButton>(find.byType(LoadingButton));
        expect(loadingButton.label, equals('Test Label'));
        expect(loadingButton.loading, isTrue);
        expect(loadingButton.width, equals(250));
      });

      testWidgets('handles default width correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingButton(
                label: 'Default Width',
                loading: false,
              ),
            ),
          ),
        );

        final loadingButton =
            tester.widget<LoadingButton>(find.byType(LoadingButton));
        expect(loadingButton.width, equals(140)); // Default width
      });
    });

    group('Accessibility Tests', () {
      testWidgets('provides proper semantics for screen readers',
          (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit Form',
          loading: false,
        ));

        // Should have semantic label
        expect(find.bySemanticsLabel('Submit Form'), findsOneWidget);
      });

      testWidgets('indicates loading state to screen readers', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Submit Form',
          loading: true,
        ));

        // When loading, the button should still be discoverable but disabled
        expect(find.byType(ElevatedButton), findsOneWidget);

        final elevatedButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(elevatedButton.onPressed, isNull);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('handles extremely long label text', (tester) async {
        final longLabel = 'a' * 1000;

        await tester.pumpWidget(createWidgetUnderTest(
          label: longLabel,
          loading: false,
        ));

        expect(find.byType(LoadingButton), findsOneWidget);
        // Should render without crashing
      });

      testWidgets('handles special characters in label', (tester) async {
        const specialLabel = r'!@#$%^&*()_+{}|:"<>?';

        await tester.pumpWidget(createWidgetUnderTest(
          label: specialLabel,
          loading: false,
        ));

        expect(find.text(specialLabel), findsOneWidget);
      });

      testWidgets('handles unicode characters in label', (tester) async {
        const unicodeLabel = '提交 (ሰብሚት)';

        await tester.pumpWidget(createWidgetUnderTest(
          label: unicodeLabel,
          loading: false,
        ));

        expect(find.text(unicodeLabel), findsOneWidget);
      });

      testWidgets('handles very small width', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Go',
          loading: false,
          width: 50,
        ));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(50));

        // Should still render correctly
        expect(find.text('Go'), findsOneWidget);
      });

      testWidgets('handles very large width', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          label: 'Very Wide Button',
          loading: false,
          width: 500,
        ));

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(500));

        // Should still render correctly
        expect(find.text('Very Wide Button'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('rebuilds efficiently on state changes', (tester) async {
        bool isLoading = false;
        int buildCount = 0;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              buildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      LoadingButton(
                        label: 'Submit',
                        loading: isLoading,
                        onPressed: () {
                          setState(() {
                            isLoading = !isLoading;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        final initialBuildCount = buildCount;

        // Toggle loading state
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should only rebuild once more
        expect(buildCount, equals(initialBuildCount + 1));
      });
    });
  });
}
