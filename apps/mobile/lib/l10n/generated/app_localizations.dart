import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dhamma Path'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Power in Every Voice'**
  String get tagline;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @languageScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Language'**
  String get languageScreenTitle;

  /// No description provided for @languageScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get languageScreenSubtitle;

  /// No description provided for @personInfoScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Person Information'**
  String get personInfoScreenTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @mobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumberLabel;

  /// No description provided for @mobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get mobileNumberHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @teacherScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Your Teacher'**
  String get teacherScreenTitle;

  /// No description provided for @teacherScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'अपने गुरु चुनें'**
  String get teacherScreenSubtitle;

  /// No description provided for @teacherSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a Teacher (e.g. Buddha)...'**
  String get teacherSearchHint;

  /// No description provided for @teacherHelperText.
  ///
  /// In en, this message translates to:
  /// **'You can select multiple Teachers to personalise your experience'**
  String get teacherHelperText;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get errorNameRequired;

  /// No description provided for @errorNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid name'**
  String get errorNameInvalid;

  /// No description provided for @errorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get errorPhoneRequired;

  /// No description provided for @errorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get errorPhoneInvalid;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorEmailInvalid;

  /// No description provided for @errorTeacherRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one teacher'**
  String get errorTeacherRequired;

  /// No description provided for @loginContinueWithOtp.
  ///
  /// In en, this message translates to:
  /// **'Continue with OTP'**
  String get loginContinueWithOtp;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the '**
  String get loginLegalPrefix;

  /// No description provided for @loginLegalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get loginLegalAnd;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// No description provided for @homeWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get homeWallpaper;

  /// No description provided for @homeMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get homeMeditation;

  /// No description provided for @homeRingtone.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get homeRingtone;

  /// No description provided for @homeSong.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get homeSong;

  /// No description provided for @homeDailyPrarthana.
  ///
  /// In en, this message translates to:
  /// **'Daily Prarthana'**
  String get homeDailyPrarthana;

  /// No description provided for @homeShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get homeShareApp;

  /// No description provided for @homeTrendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Trending Status'**
  String get homeTrendingStatus;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileMyIdCard.
  ///
  /// In en, this message translates to:
  /// **'My ID Card'**
  String get profileMyIdCard;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get profileComingSoon;

  /// No description provided for @profileChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get profileChangeLanguage;

  /// No description provided for @profileAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get profileAboutUs;

  /// No description provided for @profileContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get profileContactUs;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTermsConditions;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileMyTeachers.
  ///
  /// In en, this message translates to:
  /// **'My Teachers'**
  String get profileMyTeachers;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileRateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get profileRateUs;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Dhamma Path?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This requests deletion of your account, alarms and profile. This cannot be undone.'**
  String get profileDeleteBody;

  /// No description provided for @profileDeleteContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get profileDeleteContinue;

  /// No description provided for @profileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get profileDeleteConfirmTitle;

  /// No description provided for @profileDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Delete again to send the request and sign out.'**
  String get profileDeleteConfirmBody;

  /// No description provided for @contactSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactSubject;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// No description provided for @contactSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get contactSend;

  /// No description provided for @contactSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent.'**
  String get contactSent;

  /// No description provided for @contactFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the message.'**
  String get contactFailed;

  /// No description provided for @notifPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get notifPermissionTitle;

  /// No description provided for @notifPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for Daily Prarthana reminders and Dhamma updates.'**
  String get notifPermissionBody;

  /// No description provided for @notifPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get notifPermissionAllow;

  /// No description provided for @setWallpaperTitle.
  ///
  /// In en, this message translates to:
  /// **'Set wallpaper'**
  String get setWallpaperTitle;

  /// No description provided for @setWallpaperHome.
  ///
  /// In en, this message translates to:
  /// **'Home screen'**
  String get setWallpaperHome;

  /// No description provided for @setWallpaperLock.
  ///
  /// In en, this message translates to:
  /// **'Lock screen'**
  String get setWallpaperLock;

  /// No description provided for @setWallpaperBoth.
  ///
  /// In en, this message translates to:
  /// **'Home and lock'**
  String get setWallpaperBoth;

  /// No description provided for @wallpaperSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper set.'**
  String get wallpaperSetSuccess;

  /// No description provided for @wallpaperSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set wallpaper.'**
  String get wallpaperSetFailed;

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery.'**
  String get savedToGallery;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @ringtoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ringtones yet.'**
  String get ringtoneEmpty;

  /// No description provided for @setRingtoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Set as'**
  String get setRingtoneTitle;

  /// No description provided for @setRingtoneKind.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get setRingtoneKind;

  /// No description provided for @setAlarmKind.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get setAlarmKind;

  /// No description provided for @setNotificationKind.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get setNotificationKind;

  /// No description provided for @ringtoneSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Set as {kind}.'**
  String ringtoneSetSuccess(String kind);

  /// No description provided for @ringtoneSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set the tone.'**
  String get ringtoneSetFailed;

  /// No description provided for @ringtoneDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download the audio.'**
  String get ringtoneDownloadFailed;

  /// No description provided for @ringtoneSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your device.'**
  String get ringtoneSaved;

  /// No description provided for @ringtonePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow system settings'**
  String get ringtonePermissionTitle;

  /// No description provided for @ringtonePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'To set a ringtone, alarm or notification sound, Android needs permission to change system settings. We only use this to set the sound you chose.'**
  String get ringtonePermissionBody;

  /// No description provided for @ringtonePermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get ringtonePermissionAllow;

  /// No description provided for @ringtonePermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get ringtonePermissionNotNow;

  /// No description provided for @ringtonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission is still off. Open Help to turn it on.'**
  String get ringtonePermissionDenied;

  /// No description provided for @ringtoneHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to set a ringtone'**
  String get ringtoneHelpTitle;

  /// No description provided for @ringtoneHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Android asks for a one-time “modify system settings” permission. The app cannot set the sound without it.'**
  String get ringtoneHelpIntro;

  /// No description provided for @ringtoneHelpStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap Set on a ringtone, then pick Ringtone, Alarm or Notification.'**
  String get ringtoneHelpStep1;

  /// No description provided for @ringtoneHelpStep2.
  ///
  /// In en, this message translates to:
  /// **'If asked, tap Open settings.'**
  String get ringtoneHelpStep2;

  /// No description provided for @ringtoneHelpStep3.
  ///
  /// In en, this message translates to:
  /// **'Turn on the switch for Dhamma Path.'**
  String get ringtoneHelpStep3;

  /// No description provided for @ringtoneHelpStep4.
  ///
  /// In en, this message translates to:
  /// **'Return here — we finish setting the sound automatically.'**
  String get ringtoneHelpStep4;

  /// No description provided for @ringtoneHelpOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get ringtoneHelpOpenSettings;

  /// No description provided for @sleepTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimerTitle;

  /// No description provided for @sleepTimerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepTimerOff;

  /// No description provided for @sleepTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepTimerMinutes(int minutes);

  /// No description provided for @sleepTimerRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sleep in {time}'**
  String sleepTimerRemaining(String time);

  /// No description provided for @prarthanaAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get prarthanaAdd;

  /// No description provided for @prarthanaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No prarthana set yet. Tap Add to schedule one.'**
  String get prarthanaEmpty;

  /// No description provided for @prarthanaLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load alarms.'**
  String get prarthanaLoadFailed;

  /// No description provided for @prarthanaDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get prarthanaDelete;

  /// No description provided for @prarthanaTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get prarthanaTimeLabel;

  /// No description provided for @prarthanaEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get prarthanaEveryday;

  /// No description provided for @prarthanaSongLabel.
  ///
  /// In en, this message translates to:
  /// **'Prarthana Song'**
  String get prarthanaSongLabel;

  /// No description provided for @prarthanaNoSelection.
  ///
  /// In en, this message translates to:
  /// **'No Prarthana selected'**
  String get prarthanaNoSelection;

  /// No description provided for @prarthanaChooseSong.
  ///
  /// In en, this message translates to:
  /// **'Choose prarthana'**
  String get prarthanaChooseSong;

  /// No description provided for @prarthanaNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No prarthanas yet.'**
  String get prarthanaNoSongs;

  /// No description provided for @prarthanaSetCta.
  ///
  /// In en, this message translates to:
  /// **'Set Prarthana'**
  String get prarthanaSetCta;

  /// No description provided for @prarthanaNeedSong.
  ///
  /// In en, this message translates to:
  /// **'Choose a prarthana first.'**
  String get prarthanaNeedSong;

  /// No description provided for @prarthanaNeedDays.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day.'**
  String get prarthanaNeedDays;

  /// No description provided for @prarthanaSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Prarthana set.'**
  String get prarthanaSetSuccess;

  /// No description provided for @prarthanaSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set the prarthana.'**
  String get prarthanaSetFailed;

  /// No description provided for @prarthanaBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the alarm reliable'**
  String get prarthanaBatteryTitle;

  /// No description provided for @prarthanaBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop background alarms. Allow Dhamma Path to ignore battery optimisation.'**
  String get prarthanaBatteryBody;

  /// No description provided for @prarthanaHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How Daily Prarthana works'**
  String get prarthanaHelpTitle;

  /// No description provided for @prarthanaHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'The alarm is stored on this phone and plays even offline, after reboot, and if the app is closed.'**
  String get prarthanaHelpIntro;

  /// No description provided for @prarthanaHelpStep1.
  ///
  /// In en, this message translates to:
  /// **'Pick a time, the days it should repeat, and a prarthana song.'**
  String get prarthanaHelpStep1;

  /// No description provided for @prarthanaHelpStep2.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms and notifications if Android asks.'**
  String get prarthanaHelpStep2;

  /// No description provided for @prarthanaHelpStep3.
  ///
  /// In en, this message translates to:
  /// **'Turn off battery optimisation for Dhamma Path so the alarm is not killed.'**
  String get prarthanaHelpStep3;

  /// No description provided for @prarthanaHelpStep4.
  ///
  /// In en, this message translates to:
  /// **'When it rings, Stop or Snooze 10 minutes. It works with the app closed.'**
  String get prarthanaHelpStep4;

  /// No description provided for @prarthanaHelpBattery.
  ///
  /// In en, this message translates to:
  /// **'Open battery settings'**
  String get prarthanaHelpBattery;

  /// No description provided for @prarthanaHelpExact.
  ///
  /// In en, this message translates to:
  /// **'Open exact-alarm settings'**
  String get prarthanaHelpExact;

  /// No description provided for @prarthanaTest60.
  ///
  /// In en, this message translates to:
  /// **'Test alarm in 60 seconds'**
  String get prarthanaTest60;

  /// No description provided for @prarthanaTestArmed.
  ///
  /// In en, this message translates to:
  /// **'Test alarm in 60 seconds.'**
  String get prarthanaTestArmed;

  /// No description provided for @statusEmpty.
  ///
  /// In en, this message translates to:
  /// **'No statuses yet.'**
  String get statusEmpty;

  /// No description provided for @statusTapName.
  ///
  /// In en, this message translates to:
  /// **'Tap to add name'**
  String get statusTapName;

  /// No description provided for @statusEditName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get statusEditName;

  /// No description provided for @statusPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get statusPickGallery;

  /// No description provided for @statusPickCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get statusPickCamera;

  /// No description provided for @statusExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export the status.'**
  String get statusExportFailed;

  /// No description provided for @otpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpScreenTitle;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phone}'**
  String otpEnterCode(String phone);

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get otpChangeNumber;

  /// No description provided for @authErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'That phone number looks invalid.'**
  String get authErrorInvalidPhone;

  /// No description provided for @authErrorInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get authErrorInvalidOtp;

  /// No description provided for @authErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'That code expired. Request a new one.'**
  String get authErrorSessionExpired;

  /// No description provided for @authErrorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrorTooManyAttempts;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and retry.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorPlayIntegrity.
  ///
  /// In en, this message translates to:
  /// **'App verification failed. Please try again.'**
  String get authErrorPlayIntegrity;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some actions may fail.'**
  String get offlineBanner;

  /// No description provided for @errorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load content.'**
  String get errorLoadFailed;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version of Dhamma Path is required to continue.'**
  String get forceUpdateBody;

  /// No description provided for @forceUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get forceUpdateButton;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'We will be back shortly'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceFallback.
  ///
  /// In en, this message translates to:
  /// **'Dhamma Path is under maintenance. Please try again later.'**
  String get maintenanceFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
