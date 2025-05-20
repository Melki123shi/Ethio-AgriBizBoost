import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'common_localizations_am.dart';
import 'common_localizations_en.dart';
import 'common_localizations_om.dart';
import 'common_localizations_ti.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CommonLocalizations
/// returned by `CommonLocalizations.of(context)`.
///
/// Applications need to include `CommonLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization_classes/common_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CommonLocalizations.localizationsDelegates,
///   supportedLocales: CommonLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CommonLocalizations.supportedLocales
/// property.
abstract class CommonLocalizations {
  CommonLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CommonLocalizations? of(BuildContext context) {
    return Localizations.of<CommonLocalizations>(context, CommonLocalizations);
  }

  static const LocalizationsDelegate<CommonLocalizations> delegate = _CommonLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('om'),
    Locale('ti')
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone_number;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get already_have_account;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account'**
  String get dont_have_account;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enter_name;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enter_password;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enter_email;

  /// No description provided for @enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enter_phone;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preference.
  ///
  /// In en, this message translates to:
  /// **'Preference'**
  String get preference;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get edit_profile;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkmode.
  ///
  /// In en, this message translates to:
  /// **'Darkmode'**
  String get darkmode;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get log_out;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save_changes;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirm_new_password;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get select_language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// No description provided for @afan_oromo.
  ///
  /// In en, this message translates to:
  /// **'Afan Oromo'**
  String get afan_oromo;

  /// No description provided for @tigrigna.
  ///
  /// In en, this message translates to:
  /// **'Tigrigna'**
  String get tigrigna;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirm_logout;

  /// No description provided for @yes_logout.
  ///
  /// In en, this message translates to:
  /// **'Yes, logout'**
  String get yes_logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @forcasting.
  ///
  /// In en, this message translates to:
  /// **'Forecasting'**
  String get forcasting;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @crop_type.
  ///
  /// In en, this message translates to:
  /// **'Crop type'**
  String get crop_type;

  /// No description provided for @government_subsidy.
  ///
  /// In en, this message translates to:
  /// **'Government subsidy'**
  String get government_subsidy;

  /// No description provided for @sale_price_per_quintal.
  ///
  /// In en, this message translates to:
  /// **'Sale price per quintal'**
  String get sale_price_per_quintal;

  /// No description provided for @total_cost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get total_cost;

  /// No description provided for @quantity_sold.
  ///
  /// In en, this message translates to:
  /// **'Quantity sold'**
  String get quantity_sold;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// No description provided for @woreda.
  ///
  /// In en, this message translates to:
  /// **'Woreda'**
  String get woreda;

  /// No description provided for @market_name.
  ///
  /// In en, this message translates to:
  /// **'Market name'**
  String get market_name;

  /// No description provided for @variety_name.
  ///
  /// In en, this message translates to:
  /// **'Variety name'**
  String get variety_name;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @expense_reduction.
  ///
  /// In en, this message translates to:
  /// **'Expense reduction'**
  String get expense_reduction;

  /// No description provided for @crop_selection.
  ///
  /// In en, this message translates to:
  /// **'Crop selection'**
  String get crop_selection;

  /// No description provided for @loan_advice.
  ///
  /// In en, this message translates to:
  /// **'Loan advice'**
  String get loan_advice;

  /// No description provided for @assessment_failed.
  ///
  /// In en, this message translates to:
  /// **'Assessment failed. Please try again.'**
  String get assessment_failed;

  /// No description provided for @assessment_result.
  ///
  /// In en, this message translates to:
  /// **'Assessment Result'**
  String get assessment_result;

  /// No description provided for @price_forecast.
  ///
  /// In en, this message translates to:
  /// **'Price Forecast'**
  String get price_forecast;

  /// No description provided for @min_price.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get min_price;

  /// No description provided for @max_price.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get max_price;

  /// No description provided for @demand.
  ///
  /// In en, this message translates to:
  /// **'Demand'**
  String get demand;

  /// No description provided for @financial_stability.
  ///
  /// In en, this message translates to:
  /// **'Financial Stability'**
  String get financial_stability;

  /// No description provided for @cash_flow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cash_flow;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @dark_mode_on.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode is ON'**
  String get dark_mode_on;

  /// No description provided for @dark_mode_off.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode is OFF'**
  String get dark_mode_off;

  /// No description provided for @password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get password_updated;

  /// No description provided for @password_empty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get password_empty;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get password_too_short;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get cannot_be_empty;

  /// No description provided for @update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get update_password;

  /// No description provided for @farm_size.
  ///
  /// In en, this message translates to:
  /// **'Farm size (in hectares)'**
  String get farm_size;

  /// No description provided for @fertilizer_expense.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer expense'**
  String get fertilizer_expense;

  /// No description provided for @pesticide_expense.
  ///
  /// In en, this message translates to:
  /// **'Pesticide expense'**
  String get pesticide_expense;

  /// No description provided for @transportation_expense.
  ///
  /// In en, this message translates to:
  /// **'Transportation expense'**
  String get transportation_expense;

  /// No description provided for @equipment_expense.
  ///
  /// In en, this message translates to:
  /// **'Equipment expense'**
  String get equipment_expense;

  /// No description provided for @seed_expense.
  ///
  /// In en, this message translates to:
  /// **'Seed expense'**
  String get seed_expense;

  /// No description provided for @labour_expense.
  ///
  /// In en, this message translates to:
  /// **'Labour expense'**
  String get labour_expense;

  /// No description provided for @other_utilities.
  ///
  /// In en, this message translates to:
  /// **'Other utilities'**
  String get other_utilities;

  /// No description provided for @loan_advice_result.
  ///
  /// In en, this message translates to:
  /// **'Loan Advice Result'**
  String get loan_advice_result;

  /// No description provided for @loan_advice_failed.
  ///
  /// In en, this message translates to:
  /// **'Loan advice failed'**
  String get loan_advice_failed;

  /// No description provided for @pick_date.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pick_date;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @goods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get goods;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @price_etb.
  ///
  /// In en, this message translates to:
  /// **'Price (ETB)'**
  String get price_etb;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @add_assessment.
  ///
  /// In en, this message translates to:
  /// **'Add Assessment'**
  String get add_assessment;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @stability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get stability;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete;

  /// No description provided for @delete_entry_prompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get delete_entry_prompt;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit_entry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get edit_entry;

  /// No description provided for @edit_not_implemented.
  ///
  /// In en, this message translates to:
  /// **'Editing is not yet implemented.'**
  String get edit_not_implemented;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @expense_tracking.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracking'**
  String get expense_tracking;

  /// No description provided for @assessment_history.
  ///
  /// In en, this message translates to:
  /// **'Assessment History'**
  String get assessment_history;

  /// No description provided for @add_expense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get add_expense;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @failed_to_fetch_user.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch user'**
  String get failed_to_fetch_user;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;
}

class _CommonLocalizationsDelegate extends LocalizationsDelegate<CommonLocalizations> {
  const _CommonLocalizationsDelegate();

  @override
  Future<CommonLocalizations> load(Locale locale) {
    return SynchronousFuture<CommonLocalizations>(lookupCommonLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en', 'om', 'ti'].contains(locale.languageCode);

  @override
  bool shouldReload(_CommonLocalizationsDelegate old) => false;
}

CommonLocalizations lookupCommonLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return CommonLocalizationsAm();
    case 'en': return CommonLocalizationsEn();
    case 'om': return CommonLocalizationsOm();
    case 'ti': return CommonLocalizationsTi();
  }

  throw FlutterError(
    'CommonLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
