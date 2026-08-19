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
  String get loginLegalPrefix => 'By continuing you agree to the ';

  @override
  String get loginLegalAnd => ' and ';

  @override
  String get profileHelp => 'Help';

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

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileMyTeachers => 'My Teachers';

  @override
  String get profileSave => 'Save';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileRateUs => 'Rate Us';

  @override
  String get profileVersion => 'Version';

  @override
  String get profileLogoutConfirm => 'Sign out of Dhamma Path?';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteBody =>
      'This requests deletion of your account, alarms and profile. This cannot be undone.';

  @override
  String get profileDeleteContinue => 'Continue';

  @override
  String get profileDeleteConfirmTitle => 'Are you sure?';

  @override
  String get profileDeleteConfirmBody =>
      'Tap Delete again to send the request and sign out.';

  @override
  String get contactSubject => 'Subject';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactSend => 'Send';

  @override
  String get contactSent => 'Message sent.';

  @override
  String get contactFailed => 'Could not send the message.';

  @override
  String get notifPermissionTitle => 'Stay in the loop';

  @override
  String get notifPermissionBody =>
      'Allow notifications for Daily Prarthana reminders and Dhamma updates.';

  @override
  String get notifPermissionAllow => 'Allow';

  @override
  String get setWallpaperTitle => 'Set wallpaper';

  @override
  String get setWallpaperHome => 'Home screen';

  @override
  String get setWallpaperLock => 'Lock screen';

  @override
  String get setWallpaperBoth => 'Home and lock';

  @override
  String get wallpaperSetSuccess => 'Wallpaper set.';

  @override
  String get wallpaperSetFailed => 'Could not set wallpaper.';

  @override
  String get savedToGallery => 'Saved to gallery.';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get help => 'Help';

  @override
  String get set => 'Set';

  @override
  String get ringtoneEmpty => 'No ringtones yet.';

  @override
  String get setRingtoneTitle => 'Set as';

  @override
  String get setRingtoneKind => 'Ringtone';

  @override
  String get setAlarmKind => 'Alarm';

  @override
  String get setNotificationKind => 'Notification';

  @override
  String ringtoneSetSuccess(String kind) {
    return 'Set as $kind.';
  }

  @override
  String get ringtoneSetFailed => 'Could not set the tone.';

  @override
  String get ringtoneDownloadFailed => 'Could not download the audio.';

  @override
  String get ringtoneSaved => 'Saved to your device.';

  @override
  String get ringtonePermissionTitle => 'Allow system settings';

  @override
  String get ringtonePermissionBody =>
      'To set a ringtone, alarm or notification sound, Android needs permission to change system settings. We only use this to set the sound you chose.';

  @override
  String get ringtonePermissionAllow => 'Open settings';

  @override
  String get ringtonePermissionNotNow => 'Not now';

  @override
  String get ringtonePermissionDenied =>
      'Permission is still off. Open Help to turn it on.';

  @override
  String get ringtoneHelpTitle => 'How to set a ringtone';

  @override
  String get ringtoneHelpIntro =>
      'Android asks for a one-time “modify system settings” permission. The app cannot set the sound without it.';

  @override
  String get ringtoneHelpStep1 =>
      'Tap Set on a ringtone, then pick Ringtone, Alarm or Notification.';

  @override
  String get ringtoneHelpStep2 => 'If asked, tap Open settings.';

  @override
  String get ringtoneHelpStep3 => 'Turn on the switch for Dhamma Path.';

  @override
  String get ringtoneHelpStep4 =>
      'Return here — we finish setting the sound automatically.';

  @override
  String get ringtoneHelpOpenSettings => 'Open system settings';

  @override
  String get sleepTimerTitle => 'Sleep timer';

  @override
  String get sleepTimerOff => 'Off';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepTimerRemaining(String time) {
    return 'Sleep in $time';
  }

  @override
  String get prarthanaAdd => 'Add';

  @override
  String get prarthanaEmpty => 'No prarthana set yet. Tap Add to schedule one.';

  @override
  String get prarthanaLoadFailed => 'Could not load alarms.';

  @override
  String get prarthanaDelete => 'Delete';

  @override
  String get prarthanaTimeLabel => 'Time';

  @override
  String get prarthanaEveryday => 'Everyday';

  @override
  String get prarthanaSongLabel => 'Prarthana Song';

  @override
  String get prarthanaNoSelection => 'No Prarthana selected';

  @override
  String get prarthanaChooseSong => 'Choose prarthana';

  @override
  String get prarthanaNoSongs => 'No prarthanas yet.';

  @override
  String get prarthanaSetCta => 'Set Prarthana';

  @override
  String get prarthanaNeedSong => 'Choose a prarthana first.';

  @override
  String get prarthanaNeedDays => 'Pick at least one day.';

  @override
  String get prarthanaSetSuccess => 'Prarthana set.';

  @override
  String get prarthanaSetFailed => 'Could not set the prarthana.';

  @override
  String get prarthanaBatteryTitle => 'Keep the alarm reliable';

  @override
  String get prarthanaBatteryBody =>
      'Some phones stop background alarms. Allow Dhamma Path to ignore battery optimisation.';

  @override
  String get prarthanaHelpTitle => 'How Daily Prarthana works';

  @override
  String get prarthanaHelpIntro =>
      'The alarm is stored on this phone and plays even offline, after reboot, and if the app is closed.';

  @override
  String get prarthanaHelpStep1 =>
      'Pick a time, the days it should repeat, and a prarthana song.';

  @override
  String get prarthanaHelpStep2 =>
      'Allow exact alarms and notifications if Android asks.';

  @override
  String get prarthanaHelpStep3 =>
      'Turn off battery optimisation for Dhamma Path so the alarm is not killed.';

  @override
  String get prarthanaHelpStep4 =>
      'When it rings, Stop or Snooze 10 minutes. It works with the app closed.';

  @override
  String get prarthanaHelpBattery => 'Open battery settings';

  @override
  String get prarthanaHelpExact => 'Open exact-alarm settings';

  @override
  String get prarthanaTest60 => 'Test alarm in 60 seconds';

  @override
  String get prarthanaTestArmed => 'Test alarm in 60 seconds.';

  @override
  String get statusEmpty => 'No statuses yet.';

  @override
  String get statusTapName => 'Tap to add name';

  @override
  String get statusEditName => 'Your name';

  @override
  String get statusPickGallery => 'Gallery';

  @override
  String get statusPickCamera => 'Camera';

  @override
  String get statusExportFailed => 'Could not export the status.';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'A newer version of Dhamma Path is required to continue.';

  @override
  String get forceUpdateButton => 'Update';

  @override
  String get maintenanceTitle => 'We will be back shortly';

  @override
  String get maintenanceFallback =>
      'Dhamma Path is under maintenance. Please try again later.';
}
