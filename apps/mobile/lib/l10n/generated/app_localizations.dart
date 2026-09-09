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
  /// **'Wallpapers'**
  String get homeWallpaper;

  /// No description provided for @homeWallpaperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'HD wallpapers'**
  String get homeWallpaperSubtitle;

  /// No description provided for @homeMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get homeMeditation;

  /// No description provided for @homeMeditationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Timer & guide'**
  String get homeMeditationSubtitle;

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

  /// No description provided for @homeVandana.
  ///
  /// In en, this message translates to:
  /// **'Vandana'**
  String get homeVandana;

  /// No description provided for @vandanaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No vandana yet.'**
  String get vandanaEmpty;

  /// No description provided for @homeDailyPrarthana.
  ///
  /// In en, this message translates to:
  /// **'Daily Practice'**
  String get homeDailyPrarthana;

  /// No description provided for @meditationTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Meditation'**
  String get meditationTimerTitle;

  /// No description provided for @meditationTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a track and meditate for a set time'**
  String get meditationTimerSubtitle;

  /// No description provided for @meditationTimerTrack.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get meditationTimerTrack;

  /// No description provided for @meditationTimerNoTrack.
  ///
  /// In en, this message translates to:
  /// **'No meditation selected'**
  String get meditationTimerNoTrack;

  /// No description provided for @meditationTimerNeedTrack.
  ///
  /// In en, this message translates to:
  /// **'Choose a meditation first.'**
  String get meditationTimerNeedTrack;

  /// No description provided for @meditationTimerDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get meditationTimerDuration;

  /// No description provided for @meditationTimerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get meditationTimerStart;

  /// No description provided for @meditationTimerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get meditationTimerStop;

  /// No description provided for @meditationTimerReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get meditationTimerReady;

  /// No description provided for @meditationTimerRunning.
  ///
  /// In en, this message translates to:
  /// **'Meditating…'**
  String get meditationTimerRunning;

  /// No description provided for @meditationTimerDone.
  ///
  /// In en, this message translates to:
  /// **'Meditation complete. 🙏'**
  String get meditationTimerDone;

  /// No description provided for @meditationTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String meditationTimerMinutes(int count);

  /// No description provided for @homeShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get homeShareApp;

  /// No description provided for @homeVideo.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get homeVideo;

  /// No description provided for @homeVideoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch & learn'**
  String get homeVideoSubtitle;

  /// No description provided for @homeRingtoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dhamma Sounds & Tunes'**
  String get homeRingtoneSubtitle;

  /// No description provided for @homeSongSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dhamma Music'**
  String get homeSongSubtitle;

  /// No description provided for @homeVandanaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buddha Puja & Homage'**
  String get homeVandanaSubtitle;

  /// No description provided for @videosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No videos yet.'**
  String get videosEmpty;

  /// No description provided for @videoOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the video.'**
  String get videoOpenFailed;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navExplore;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @themeAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @todayWisdom.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Wisdom'**
  String get todayWisdom;

  /// No description provided for @todayWisdomReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get todayWisdomReadMore;

  /// No description provided for @homeTrendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Trending Status'**
  String get homeTrendingStatus;

  /// No description provided for @homeBuddhistCalendar.
  ///
  /// In en, this message translates to:
  /// **'Buddhist Calendar'**
  String get homeBuddhistCalendar;

  /// No description provided for @homeBuddhistCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uposatha • Festivals'**
  String get homeBuddhistCalendarSubtitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Buddhist Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarSelectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected date'**
  String get calendarSelectedDate;

  /// No description provided for @calendarNoObservance.
  ///
  /// In en, this message translates to:
  /// **'No marked observance on this date.'**
  String get calendarNoObservance;

  /// No description provided for @calendarUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming observances'**
  String get calendarUpcoming;

  /// No description provided for @calendarThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get calendarThisMonth;

  /// No description provided for @calendarUposatha.
  ///
  /// In en, this message translates to:
  /// **'Uposatha'**
  String get calendarUposatha;

  /// No description provided for @calendarNewMoon.
  ///
  /// In en, this message translates to:
  /// **'New Moon'**
  String get calendarNewMoon;

  /// No description provided for @calendarFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First Quarter'**
  String get calendarFirstQuarter;

  /// No description provided for @calendarFullMoon.
  ///
  /// In en, this message translates to:
  /// **'Full Moon'**
  String get calendarFullMoon;

  /// No description provided for @calendarLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Last Quarter'**
  String get calendarLastQuarter;

  /// No description provided for @calendarFestival.
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get calendarFestival;

  /// No description provided for @calendarEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get calendarEstimated;

  /// No description provided for @calendarNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'About these dates'**
  String get calendarNoticeTitle;

  /// No description provided for @calendarEstimateNotice.
  ///
  /// In en, this message translates to:
  /// **'Lunar Uposatha and festival dates are estimates based on moon phases. They may vary by a day, country or Buddhist tradition. Please confirm with your local monastery.'**
  String get calendarEstimateNotice;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarNewMoonUposatha.
  ///
  /// In en, this message translates to:
  /// **'New Moon Uposatha'**
  String get calendarNewMoonUposatha;

  /// No description provided for @calendarFirstQuarterUposatha.
  ///
  /// In en, this message translates to:
  /// **'First Quarter Uposatha'**
  String get calendarFirstQuarterUposatha;

  /// No description provided for @calendarFullMoonUposatha.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Uposatha'**
  String get calendarFullMoonUposatha;

  /// No description provided for @calendarLastQuarterUposatha.
  ///
  /// In en, this message translates to:
  /// **'Last Quarter Uposatha'**
  String get calendarLastQuarterUposatha;

  /// No description provided for @calendarMaghaPuja.
  ///
  /// In en, this message translates to:
  /// **'Magha Puja (Sangha Day)'**
  String get calendarMaghaPuja;

  /// No description provided for @calendarParinirvanaDay.
  ///
  /// In en, this message translates to:
  /// **'Parinirvana Day'**
  String get calendarParinirvanaDay;

  /// No description provided for @calendarVesak.
  ///
  /// In en, this message translates to:
  /// **'Vesak (Buddha Day)'**
  String get calendarVesak;

  /// No description provided for @calendarAsalhaPuja.
  ///
  /// In en, this message translates to:
  /// **'Asalha Puja (Dhamma Day)'**
  String get calendarAsalhaPuja;

  /// No description provided for @calendarPavarana.
  ///
  /// In en, this message translates to:
  /// **'Pavarana Day'**
  String get calendarPavarana;

  /// No description provided for @calendarDhammaChakraDay.
  ///
  /// In en, this message translates to:
  /// **'Dhammachakra Pravartan Day'**
  String get calendarDhammaChakraDay;

  /// No description provided for @calendarBodhiDay.
  ///
  /// In en, this message translates to:
  /// **'Bodhi Day'**
  String get calendarBodhiDay;

  /// No description provided for @calendarUposathaDescription.
  ///
  /// In en, this message translates to:
  /// **'A day for deeper practice, meditation, generosity and observing the precepts.'**
  String get calendarUposathaDescription;

  /// No description provided for @calendarMaghaDescription.
  ///
  /// In en, this message translates to:
  /// **'Remembers the spontaneous gathering of the Buddha\'s enlightened disciples.'**
  String get calendarMaghaDescription;

  /// No description provided for @calendarParinirvanaDescription.
  ///
  /// In en, this message translates to:
  /// **'Commemorates the Buddha\'s passing into final Nibbana in Mahayana traditions.'**
  String get calendarParinirvanaDescription;

  /// No description provided for @calendarVesakDescription.
  ///
  /// In en, this message translates to:
  /// **'Honours the Buddha\'s birth, awakening and final Nibbana.'**
  String get calendarVesakDescription;

  /// No description provided for @calendarAsalhaDescription.
  ///
  /// In en, this message translates to:
  /// **'Remembers the Buddha\'s first teaching and the arising of the Sangha.'**
  String get calendarAsalhaDescription;

  /// No description provided for @calendarPavaranaDescription.
  ///
  /// In en, this message translates to:
  /// **'Marks the end of the traditional rains retreat.'**
  String get calendarPavaranaDescription;

  /// No description provided for @calendarDhammaChakraDescription.
  ///
  /// In en, this message translates to:
  /// **'Commemorates the historic Buddhist conversion at Deekshabhoomi, Nagpur.'**
  String get calendarDhammaChakraDescription;

  /// No description provided for @calendarBodhiDescription.
  ///
  /// In en, this message translates to:
  /// **'Commemorates the Buddha\'s awakening in several Mahayana traditions.'**
  String get calendarBodhiDescription;

  /// No description provided for @homeDailyPaliWord.
  ///
  /// In en, this message translates to:
  /// **'Daily Pali Word'**
  String get homeDailyPaliWord;

  /// No description provided for @homeDailyPaliWordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn one word daily'**
  String get homeDailyPaliWordSubtitle;

  /// No description provided for @homeChanting.
  ///
  /// In en, this message translates to:
  /// **'Chanting'**
  String get homeChanting;

  /// No description provided for @homeChantingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Audio collection'**
  String get homeChantingSubtitle;

  /// No description provided for @chantingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No chants yet.'**
  String get chantingEmpty;

  /// No description provided for @homeTipitaka.
  ///
  /// In en, this message translates to:
  /// **'Tipitaka'**
  String get homeTipitaka;

  /// No description provided for @homeTipitakaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read scriptures'**
  String get homeTipitakaSubtitle;

  /// No description provided for @homeDana.
  ///
  /// In en, this message translates to:
  /// **'Daan'**
  String get homeDana;

  /// No description provided for @homeDanaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support this app'**
  String get homeDanaSubtitle;

  /// No description provided for @danaTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation & Support'**
  String get danaTitle;

  /// No description provided for @danaTagline.
  ///
  /// In en, this message translates to:
  /// **'Your support keeps this app alive.'**
  String get danaTagline;

  /// No description provided for @danaScanPay.
  ///
  /// In en, this message translates to:
  /// **'Scan & Pay'**
  String get danaScanPay;

  /// No description provided for @danaAnyUpiApp.
  ///
  /// In en, this message translates to:
  /// **'Any UPI app'**
  String get danaAnyUpiApp;

  /// No description provided for @danaUpiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get danaUpiId;

  /// No description provided for @danaCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get danaCopy;

  /// No description provided for @danaCopied.
  ///
  /// In en, this message translates to:
  /// **'UPI ID copied'**
  String get danaCopied;

  /// No description provided for @danaSaveQr.
  ///
  /// In en, this message translates to:
  /// **'Save QR'**
  String get danaSaveQr;

  /// No description provided for @danaBlessing.
  ///
  /// In en, this message translates to:
  /// **'May all beings be happy'**
  String get danaBlessing;

  /// No description provided for @danaDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is a voluntary charitable donation to support the running of this app. It is not a purchase and does not unlock any features or content.'**
  String get danaDisclaimer;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Dhamma Path Premium'**
  String get premiumTitle;

  /// No description provided for @premiumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unlock everything'**
  String get premiumHeadline;

  /// No description provided for @premiumSubhead.
  ///
  /// In en, this message translates to:
  /// **'One plan unlocks all wallpapers, ringtones, songs, meditations, chanting, vandana and videos.'**
  String get premiumSubhead;

  /// No description provided for @premiumBenefitWallpapers.
  ///
  /// In en, this message translates to:
  /// **'Set unlimited HD wallpapers'**
  String get premiumBenefitWallpapers;

  /// No description provided for @premiumBenefitRingtones.
  ///
  /// In en, this message translates to:
  /// **'Set any ringtone, alarm or notification tone'**
  String get premiumBenefitRingtones;

  /// No description provided for @premiumBenefitAudio.
  ///
  /// In en, this message translates to:
  /// **'All songs, meditations, chanting & vandana'**
  String get premiumBenefitAudio;

  /// No description provided for @premiumBenefitVideos.
  ///
  /// In en, this message translates to:
  /// **'All videos'**
  String get premiumBenefitVideos;

  /// No description provided for @premiumBenefitAdFree.
  ///
  /// In en, this message translates to:
  /// **'Support the app and its mission'**
  String get premiumBenefitAdFree;

  /// No description provided for @premiumPlanName.
  ///
  /// In en, this message translates to:
  /// **'Premium Monthly'**
  String get premiumPlanName;

  /// No description provided for @premiumPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get premiumPerMonth;

  /// No description provided for @premiumTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'3 days free, then billed monthly'**
  String get premiumTrialBadge;

  /// No description provided for @premiumStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 3-day free trial'**
  String get premiumStartTrial;

  /// No description provided for @premiumTrialNote.
  ///
  /// In en, this message translates to:
  /// **'Free for 3 days, then ₹199/month. Cancel anytime in Google Play.'**
  String get premiumTrialNote;

  /// No description provided for @premiumRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get premiumRestore;

  /// No description provided for @premiumRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restore complete. If you have an active plan it is now active.'**
  String get premiumRestoreDone;

  /// No description provided for @premiumStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable. Please try again later.'**
  String get premiumStoreUnavailable;

  /// No description provided for @premiumThankYou.
  ///
  /// In en, this message translates to:
  /// **'You are now Premium. Enjoy!'**
  String get premiumThankYou;

  /// No description provided for @premiumLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically. See '**
  String get premiumLegalPrefix;

  /// No description provided for @premiumLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumLockedTitle;

  /// No description provided for @homeBuddhistPlaces.
  ///
  /// In en, this message translates to:
  /// **'Buddhist Places'**
  String get homeBuddhistPlaces;

  /// No description provided for @homeBuddhistPlacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sacred sites'**
  String get homeBuddhistPlacesSubtitle;

  /// No description provided for @placesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places yet.'**
  String get placesEmpty;

  /// No description provided for @featureComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'We are preparing this feature for you.'**
  String get featureComingSoonBody;

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
  /// **'Allow notifications for Daily Practice reminders and Dhamma updates.'**
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

  /// No description provided for @setWallpaperLive.
  ///
  /// In en, this message translates to:
  /// **'Set live wallpaper'**
  String get setWallpaperLive;

  /// No description provided for @setWallpaperLivePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing live wallpaper…'**
  String get setWallpaperLivePreparing;

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

  /// No description provided for @mediaNotifPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications to control playback from the notification panel.'**
  String get mediaNotifPermissionMessage;

  /// No description provided for @mediaNotifPermissionAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get mediaNotifPermissionAction;

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
  /// **'Vandana'**
  String get prarthanaSongLabel;

  /// No description provided for @prarthanaNoSelection.
  ///
  /// In en, this message translates to:
  /// **'No vandana selected'**
  String get prarthanaNoSelection;

  /// No description provided for @prarthanaChooseSong.
  ///
  /// In en, this message translates to:
  /// **'Choose vandana'**
  String get prarthanaChooseSong;

  /// No description provided for @prarthanaNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No vandanas yet.'**
  String get prarthanaNoSongs;

  /// No description provided for @prarthanaSetCta.
  ///
  /// In en, this message translates to:
  /// **'Set Vandana'**
  String get prarthanaSetCta;

  /// No description provided for @prarthanaNeedSong.
  ///
  /// In en, this message translates to:
  /// **'Choose a vandana first.'**
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
  /// **'If a phone misses the alarm'**
  String get prarthanaBatteryTitle;

  /// No description provided for @prarthanaBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones pause background apps. In App info, set Battery to Unrestricted. This is optional and only needed on some devices.'**
  String get prarthanaBatteryBody;

  /// No description provided for @prarthanaExactTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms'**
  String get prarthanaExactTitle;

  /// No description provided for @prarthanaExactBody.
  ///
  /// In en, this message translates to:
  /// **'Daily Practice needs Alarms & reminders so it can ring at the time you chose, even when the app is closed.'**
  String get prarthanaExactBody;

  /// No description provided for @prarthanaHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How Daily Practice works'**
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
  /// **'Allow notifications and exact alarms if Android asks.'**
  String get prarthanaHelpStep2;

  /// No description provided for @prarthanaHelpStep3.
  ///
  /// In en, this message translates to:
  /// **'If a phone still misses the alarm, open App info and set Battery to Unrestricted. This is optional and only needed on some devices.'**
  String get prarthanaHelpStep3;

  /// No description provided for @prarthanaHelpStep4.
  ///
  /// In en, this message translates to:
  /// **'When it rings, use Stop or Snooze on the notification. It works with the app closed.'**
  String get prarthanaHelpStep4;

  /// No description provided for @prarthanaHelpBattery.
  ///
  /// In en, this message translates to:
  /// **'Open app battery settings'**
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
