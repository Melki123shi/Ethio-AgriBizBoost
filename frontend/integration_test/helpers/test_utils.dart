import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUtils {
  /// Fill a form field with the given text by hint text
  static Future<void> fillField(
    WidgetTester tester,
    String hintText,
    String value,
  ) async {
    final field = find.widgetWithText(CustomInputField, hintText);
    expect(field, findsOneWidget,
        reason: 'Should find field with hint: $hintText');
    await tester.enterText(field, value);
    await tester.pump();
  }

  /// Fill a form field by finding TextFormField with hint text (for more precise targeting)
  static Future<void> fillTextFormField(
    WidgetTester tester,
    String hintText,
    String value,
  ) async {
    final field = find.widgetWithText(TextFormField, hintText);
    expect(field, findsOneWidget,
        reason: 'Should find TextFormField with hint: $hintText');
    await tester.enterText(field, value);
    await tester.pump();
  }

  /// Tap a button by text and wait for animations
  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    // Try different strategies to find the button
    Finder? button;

    // First try to find it as a direct text widget
    final textWidgets = find.text(buttonText);
    if (textWidgets.evaluate().isNotEmpty) {
      button = textWidgets.first;
    } else {
      // Try to find it in LoadingButton
      final loadingButtons = find.byType(LoadingButton);
      for (final loadingButton in loadingButtons.evaluate()) {
        final widget = loadingButton.widget as LoadingButton;
        if (widget.label == buttonText) {
          button = find.byWidget(widget);
          break;
        }
      }

      // If still not found, try to find RichText containing the text
      if (button == null) {
        final richTexts = find.byType(RichText);
        for (final richTextElement in richTexts.evaluate()) {
          final richTextWidget = richTextElement.widget as RichText;
          final textSpan = richTextWidget.text;
          if (_containsText(textSpan, buttonText)) {
            button = find.byWidget(richTextWidget);
            break;
          }
        }
      }
    }

    expect(button, isNotNull,
        reason: 'Should find button with text: $buttonText');
    await tester.tap(button!);
    await tester.pumpAndSettle();
  }

  /// Helper method to check if a TextSpan contains specific text
  static bool _containsText(InlineSpan span, String targetText) {
    if (span is TextSpan) {
      // Check the main text
      if (span.text != null && span.text!.contains(targetText)) {
        return true;
      }
      // Check children TextSpans
      if (span.children != null) {
        for (final child in span.children!) {
          if (_containsText(child, targetText)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Tap a button specifically by finding RichText with the given text
  static Future<void> tapRichTextButton(
      WidgetTester tester, String buttonText) async {
    final button = find.widgetWithText(RichText, buttonText);
    expect(button, findsAtLeastNWidgets(1),
        reason: 'Should find RichText button with text: $buttonText');
    await tester.tap(button.first);
    await tester.pumpAndSettle();
  }

  /// Tap a LoadingButton by its label text
  static Future<void> tapLoadingButtonByLabel(
      WidgetTester tester, String label) async {
    final loadingButtons = find.byType(LoadingButton);
    LoadingButton? targetButton;

    for (final element in loadingButtons.evaluate()) {
      final widget = element.widget as LoadingButton;
      if (widget.label == label) {
        targetButton = widget;
        break;
      }
    }

    expect(targetButton, isNotNull,
        reason: 'Should find LoadingButton with label: $label');
    await tester.tap(find.byWidget(targetButton!));
    await tester.pumpAndSettle();
  }

  /// Tap a loading button specifically
  static Future<void> tapLoadingButton(WidgetTester tester) async {
    final button = find.byType(LoadingButton);
    expect(button, findsOneWidget, reason: 'Should find LoadingButton');
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  /// Tap any MaterialButton (ElevatedButton, TextButton, etc.)
  static Future<void> tapMaterialButton(WidgetTester tester) async {
    final button = find.byType(MaterialButton);
    expect(button, findsOneWidget, reason: 'Should find MaterialButton');
    await tester.tap(button);
    await tester.pump(); // Don't use pumpAndSettle to catch loading states
  }

  /// Wait for a specific widget to appear with timeout
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pump();
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Widget not found within timeout: $finder');
  }

  /// Wait for widget to disappear
  static Future<void> waitForWidgetToDisappear(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pump();
      if (finder.evaluate().isEmpty) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Widget did not disappear within timeout: $finder');
  }

  /// Wait for navigation to complete with longer timeout for integration tests
  static Future<void> waitForNavigation(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Verify that a snackbar with specific text is shown
  static void expectSnackbar(String message) {
    expect(find.text(message), findsOneWidget,
        reason: 'Should show snackbar with message: $message');
  }

  /// Verify that we're on a specific screen by checking for a unique widget
  static void expectScreen(Finder screenIndicator) {
    expect(screenIndicator, findsOneWidget,
        reason: 'Should be on screen indicated by: $screenIndicator');
  }

  /// Fill out the signup form with comprehensive data handling
  static Future<void> fillSignupForm(
    WidgetTester tester, {
    String? name,
    String? phoneNumber,
    String? email,
    String? password,
    bool clearFirst = true,
  }) async {
    if (clearFirst) {
      // Clear existing form data first
      await _clearFormFields(tester);
    }

    if (name != null) {
      await fillField(tester, 'Enter your name', name);
    }

    if (phoneNumber != null) {
      await fillField(tester, 'Enter your phone number', phoneNumber);
    }

    if (email != null) {
      await fillField(tester, 'Enter your email', email);
    }

    if (password != null) {
      await fillField(tester, 'Enter your password', password);
    }

    // Small delay to ensure all form updates are processed
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Fill out the login form
  static Future<void> fillLoginForm(
    WidgetTester tester, {
    required String phoneNumber,
    required String password,
    bool clearFirst = true,
  }) async {
    if (clearFirst) {
      await _clearFormFields(tester);
    }

    await fillField(tester, 'Enter your phone number', phoneNumber);
    await fillField(tester, 'Enter your password', password);

    // Small delay to ensure all form updates are processed
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Clear all form fields by setting them to empty string
  static Future<void> _clearFormFields(WidgetTester tester) async {
    final textFields = find.byType(TextFormField);
    for (int i = 0; i < textFields.evaluate().length; i++) {
      final field = textFields.at(i);
      await tester.enterText(field, '');
    }
    await tester.pump();
  }

  /// Verify form validation state
  static void expectFormValidationError(String errorMessage) {
    expect(find.text(errorMessage), findsOneWidget,
        reason: 'Should show validation error: $errorMessage');
  }

  /// Verify no validation errors are shown
  static void expectNoValidationErrors(List<String> possibleErrors) {
    for (final error in possibleErrors) {
      expect(find.text(error), findsNothing,
          reason: 'Should not show validation error: $error');
    }
  }

  /// Check if loading indicator is visible
  static void expectLoadingState() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason: 'Should show loading indicator');
  }

  /// Check if loading indicator is not visible
  static void expectNotLoadingState() {
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'Should not show loading indicator');
  }

  /// Verify button is disabled
  static void expectButtonDisabled(String buttonText) {
    final button = find.text(buttonText);
    expect(button, findsOneWidget);

    final buttonWidget =
        find.ancestor(of: button, matching: find.byType(MaterialButton));

    final materialButton = tester.widget<MaterialButton>(buttonWidget);
    expect(materialButton.onPressed, isNull,
        reason: 'Button should be disabled: $buttonText');
  }

  /// Verify button is enabled
  static void expectButtonEnabled(String buttonText) {
    final button = find.text(buttonText);
    expect(button, findsOneWidget);

    final buttonWidget =
        find.ancestor(of: button, matching: find.byType(MaterialButton));

    final materialButton = tester.widget<MaterialButton>(buttonWidget);
    expect(materialButton.onPressed, isNotNull,
        reason: 'Button should be enabled: $buttonText');
  }

  /// Navigate using app's navigation system
  static Future<void> navigateToProfile(WidgetTester tester) async {
    final profileIcon = find.byIcon(Icons.person);
    expect(profileIcon, findsOneWidget, reason: 'Should find profile icon');
    await tester.tap(profileIcon);
    await tester.pumpAndSettle();
  }

  /// Test data constants - Ethiopian context
  static const testPhoneNumber = '0911234567';
  static const testPhoneNumberWithCountryCode = '+251911234567';
  static const testPassword = 'SecurePass123';
  static const testEmail = 'abebe.kebede@test.et';
  static const testName = 'አበበ ከበደ'; // Amharic name
  static const testNameLatin = 'Abebe Kebede';

  /// Invalid test credentials for validation testing
  static const invalidPhoneNumbers = [
    '123456', // Too short
    '+1234567890', // Wrong country code
    '08123456789', // Wrong prefix
    '+25191234567', // Wrong format
    'abcdefghij', // Non-numeric
    '091234567890', // Too long
  ];

  static const shortPassword = '1234567'; // 7 chars - too short
  static const validPassword = '12345678'; // Minimum valid
  static const strongPassword = 'Str0ng!P@ssw0rd';

  static const invalidEmails = [
    'invalid-email',
    '@domain.com',
    'user@',
    'user.domain.com',
    'user @domain.com',
    'user@domain',
  ];

  static const validEmails = [
    'user@example.com',
    'test.user@domain.co.uk',
    'user+tag@example.org',
    'user123@test-domain.com',
    'አበበ@example.et', // Unicode in local part
  ];

  /// Common validation error messages
  static const validationErrors = [
    'Enter a valid Ethiopian phone number.',
    'Password must be at least 8 characters.',
    'Enter a valid email address.',
    'Please correct the highlighted fields.',
  ];

  /// Success messages
  static const successMessages = [
    'Account created. Please log in.',
    'Login successful',
    'Logout successful',
  ];

  /// Helper to get tester widget for more complex assertions
  static WidgetTester? _currentTester;

  static void setTesterContext(WidgetTester tester) {
    _currentTester = tester;
  }

  static WidgetTester get tester {
    if (_currentTester == null) {
      throw Exception(
          'Tester context not set. Call TestUtils.setTesterContext() first.');
    }
    return _currentTester!;
  }

  /// Advanced form interaction - select dropdown, radio buttons, etc.
  static Future<void> selectDropdownItem(
    WidgetTester tester,
    String dropdownValue,
  ) async {
    final dropdown = find.byType(DropdownButton);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final item = find.text(dropdownValue);
    await tester.tap(item);
    await tester.pumpAndSettle();
  }

  /// Scroll to find widget if not visible
  static Future<void> scrollToWidget(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
  }) async {
    final targetScrollable = scrollable ?? find.byType(Scrollable);

    if (targetScrollable.evaluate().isEmpty) {
      return; // No scrollable found
    }

    await tester.scrollUntilVisible(
      finder,
      100.0,
      scrollable: targetScrollable,
    );
    await tester.pumpAndSettle();
  }

  /// Test Ethiopian phone number formats comprehensively
  static Future<void> testPhoneNumberValidation(
    WidgetTester tester, {
    required List<String> validNumbers,
    required List<String> invalidNumbers,
  }) async {
    // Test valid numbers
    for (final number in validNumbers) {
      await fillSignupForm(
        tester,
        phoneNumber: number,
        password: validPassword,
      );
      await tapLoadingButton(tester);
      await tester.pump();

      expect(find.text('Enter a valid Ethiopian phone number.'), findsNothing,
          reason: 'Should accept valid number: $number');
    }

    // Test invalid numbers
    for (final number in invalidNumbers) {
      await fillSignupForm(
        tester,
        phoneNumber: number,
        password: validPassword,
      );
      await tapLoadingButton(tester);
      await tester.pump();

      expect(find.text('Enter a valid Ethiopian phone number.'), findsOneWidget,
          reason: 'Should reject invalid number: $number');
    }
  }

  /// Comprehensive email validation testing
  static Future<void> testEmailValidation(
    WidgetTester tester, {
    required List<String> validEmails,
    required List<String> invalidEmails,
  }) async {
    // Test valid emails
    for (final email in validEmails) {
      await fillSignupForm(
        tester,
        phoneNumber: testPhoneNumber,
        password: validPassword,
        email: email,
      );
      await tapLoadingButton(tester);
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsNothing,
          reason: 'Should accept valid email: $email');
    }

    // Test invalid emails
    for (final email in invalidEmails) {
      await fillSignupForm(
        tester,
        phoneNumber: testPhoneNumber,
        password: validPassword,
        email: email,
      );
      await tapLoadingButton(tester);
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget,
          reason: 'Should reject invalid email: $email');
    }
  }
}
