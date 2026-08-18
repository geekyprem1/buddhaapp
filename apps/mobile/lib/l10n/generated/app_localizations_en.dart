// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dhamma Path';

  @override
  String get tagline => 'Power in Every Voice';

  @override
  String get continueButton => 'Continue';

  @override
  String get retryButton => 'Retry';

  @override
  String get languageScreenTitle => 'Your Language';

  @override
  String get languageScreenSubtitle => 'Select your language';

  @override
  String get personInfoScreenTitle => 'Person Information';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get mobileNumberLabel => 'Mobile Number';

  @override
  String get mobileNumberHint => 'Enter 10-digit mobile number';

  @override
  String get emailLabel => 'Email';

  @override
  String get teacherScreenTitle => 'Select Your Teacher';

  @override
  String get teacherScreenSubtitle => 'अपने गुरु चुनें';

  @override
  String get teacherSearchHint => 'Search for a Teacher (e.g. Buddha)...';

  @override
  String get teacherHelperText =>
      'You can select multiple Teachers to personalise your experience';

  @override
  String get errorNameRequired => 'Please enter your name';

  @override
  String get errorNameInvalid => 'Please enter a valid name';

  @override
  String get errorPhoneRequired => 'Please enter your mobile number';

  @override
  String get errorPhoneInvalid => 'Please enter a valid 10-digit mobile number';

  @override
  String get errorEmailInvalid => 'Please enter a valid email address';

  @override
  String get errorTeacherRequired => 'Please select at least one teacher';

  @override
  String get loginContinueWithOtp => 'Continue with OTP';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get homeWallpaper => 'Wallpaper';

  @override
  String get homeMeditation => 'Meditation';

  @override
  String get homeRingtone => 'Ringtone';

  @override
  String get homeSong => 'Song';

  @override
  String get homeDailyPrarthana => 'Daily Prarthana';

  @override
  String get homeShareApp => 'Share App';

  @override
  String get homeTrendingStatus => 'Trending Status';

  @override
  String get filterAll => 'All';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileMyIdCard => 'My ID Card';

  @override
  String get profileComingSoon => 'Coming soon';

  @override
  String get profileChangeLanguage => 'Change Language';

  @override
  String get profileAboutUs => 'About Us';

  @override
  String get profileContactUs => 'Contact Us';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsConditions => 'Terms & Conditions';

  @override
  String get profileLogout => 'Logout';
}
