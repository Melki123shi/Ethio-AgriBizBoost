import 'package:app/presentation/ui/auth/login.dart';
import 'package:app/presentation/ui/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class NavigationHelpers {
  /// Navigates to the signup screen from the login screen by tapping the "Sign Up" link.
  static Future<void> navigateToSignupFromLogin(WidgetTester tester) async {
    // 1. VERIFY STATE: Ensure we are on the Login screen before we begin.
    expect(find.byType(LoginScreen), findsOneWidget,
        reason: 'Should be on the Login screen to start.');

    // Debug: Print all RichText widgets (comment out for clean test output)
    // debugPrintRichTexts(tester);

    // 2. FIND WIDGET: Try multiple approaches to find and tap the Sign Up link

    // First try: Find any Text widget with "Sign Up"
    var signUpFinder = find.text('Sign Up');
    if (signUpFinder.evaluate().isNotEmpty) {
      print('Found Sign Up as Text widget');
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();

      // Check if navigation occurred
      if (find.byType(SignupScreen).evaluate().isNotEmpty) {
        return;
      }
    }

    // Second try: Find RichText and tap on it
    final richTextFinder = find.byWidgetPredicate(
      (widget) {
        if (widget is RichText) {
          final text = _extractFullText(widget.text);
          return text.contains("Don't have an account?") &&
              text.contains("Sign Up");
        }
        return false;
      },
      description: 'RichText with signup link',
    );

    if (richTextFinder.evaluate().isNotEmpty) {
      print('Found RichText with Sign Up link');
      await tester.ensureVisible(richTextFinder);
      await tester.pumpAndSettle();

      // Try tapping at the end of the RichText where "Sign Up" should be
      final RenderBox box = tester.renderObject(richTextFinder);
      final Offset topRight =
          box.localToGlobal(Offset(box.size.width * 0.9, box.size.height / 2));
      await tester.tapAt(topRight);
      await tester.pumpAndSettle();

      // Check if navigation occurred
      if (find.byType(SignupScreen).evaluate().isNotEmpty) {
        return;
      }

      // If that didn't work, try center tap
      await tester.tap(richTextFinder);
      await tester.pumpAndSettle();
    }

    // Final verification
    expect(find.byType(SignupScreen), findsOneWidget,
        reason:
            'Should navigate to the Sign Up screen after tapping the link.');
  }

  /// Navigates to the login screen from the signup screen by tapping the "Login" link.
  static Future<void> navigateToLoginFromSignup(WidgetTester tester) async {
    // 1. VERIFY STATE: Ensure we are on the Signup screen.
    expect(find.byType(SignupScreen), findsOneWidget,
        reason: 'Should be on the Sign Up screen to start.');

    // Debug: Print all RichText widgets (comment out for clean test output)
    // debugPrintRichTexts(tester);

    // 2. Find RichText with Login link
    final richTextFinder = find.byWidgetPredicate(
      (widget) {
        if (widget is RichText) {
          final text = _extractFullText(widget.text);
          return text.contains("Already have an account?") &&
              text.contains("Login");
        }
        return false;
      },
      description: 'RichText with login link',
    );

    if (richTextFinder.evaluate().isNotEmpty) {
      print('Found RichText with Login link');
      await tester.ensureVisible(richTextFinder);
      await tester.pumpAndSettle();

      // Get the position and size of the RichText
      final RenderBox box = tester.renderObject(richTextFinder);

      // Try different tap positions to hit the "Login" text
      // "Login" is at the end, so try tapping at 85% of the width
      final Offset tapPosition =
          box.localToGlobal(Offset(box.size.width * 0.85, box.size.height / 2));

      print('Tapping at position: $tapPosition');
      await tester.tapAt(tapPosition);
      await tester.pumpAndSettle();

      // Check if navigation occurred
      if (find.byType(LoginScreen).evaluate().isNotEmpty) {
        print('Navigation successful!');
        return;
      }

      // If that didn't work, try tapping closer to the end
      final Offset endPosition =
          box.localToGlobal(Offset(box.size.width * 0.95, box.size.height / 2));

      print('Trying end position: $endPosition');
      await tester.tapAt(endPosition);
      await tester.pumpAndSettle();

      if (find.byType(LoginScreen).evaluate().isNotEmpty) {
        print('Navigation successful with end tap!');
        return;
      }

      // Last resort: tap the center
      print('Trying center tap');
      await tester.tap(richTextFinder);
      await tester.pumpAndSettle();
    }

    // Final verification
    expect(find.byType(LoginScreen), findsOneWidget,
        reason: 'Should navigate to the Login screen after tapping the link.');
  }

  /// Debug helper to print all RichText widgets on screen
  static void debugPrintRichTexts(WidgetTester tester) {
    print('\n=== Debugging RichText widgets ===');
    final richTexts = find.byType(RichText).evaluate();
    print('Found ${richTexts.length} RichText widgets');

    int index = 0;
    for (final element in richTexts) {
      final widget = element.widget as RichText;
      final text = _extractFullText(widget.text);
      print('RichText[$index]: "$text"');
      index++;
    }

    // Also check for Text widgets
    final textWidgets = find.byType(Text).evaluate();
    print('\nFound ${textWidgets.length} Text widgets');
    for (final element in textWidgets) {
      final widget = element.widget as Text;
      print('Text: "${widget.data}"');
    }
    print('=================================\n');
  }

  /// Extract full text from InlineSpan
  static String _extractFullText(InlineSpan span) {
    final buffer = StringBuffer();
    _visitTextSpans(span, (text) => buffer.write(text));
    return buffer.toString();
  }

  /// Visit all text spans recursively
  static void _visitTextSpans(InlineSpan span, void Function(String) visitor) {
    if (span is TextSpan) {
      if (span.text != null) {
        visitor(span.text!);
      }
      if (span.children != null) {
        for (final child in span.children!) {
          _visitTextSpans(child, visitor);
        }
      }
    }
  }

  /// Helper method to check if a TextSpan (or its children) contains specific text
  static bool _containsText(TextSpan span, String searchText) {
    // Check the main text
    if (span.text?.contains(searchText) ?? false) {
      return true;
    }

    // Check children TextSpans
    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan) {
          if (_containsText(child, searchText)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
