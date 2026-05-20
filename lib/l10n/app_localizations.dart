import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('ur'),
  ];

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get urdu;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @areYouClientOrWorker.
  ///
  /// In en, this message translates to:
  /// **'Are you a client or a worker?'**
  String get areYouClientOrWorker;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @clientDesc.
  ///
  /// In en, this message translates to:
  /// **'I need to hire someone for a job'**
  String get clientDesc;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @workerDesc.
  ///
  /// In en, this message translates to:
  /// **'I want to offer my services'**
  String get workerDesc;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to your KaamKaar account'**
  String get loginToContinue;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @getOTP.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOTP;

  /// No description provided for @whatDoYouNeed.
  ///
  /// In en, this message translates to:
  /// **'What service\ndo you need?'**
  String get whatDoYouNeed;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Bolo kya chahiye? Book in 60 seconds 🎙️'**
  String get aiPromptHint;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @topRatedNearby.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Nearby'**
  String get topRatedNearby;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Providers'**
  String get resultsTitle;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @providerDetails.
  ///
  /// In en, this message translates to:
  /// **'Provider Details'**
  String get providerDetails;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @driverEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Worker En Route'**
  String get driverEnRoute;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// No description provided for @workerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Worker Dashboard'**
  String get workerDashboard;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @newRequests.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get newRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @rateService.
  ///
  /// In en, this message translates to:
  /// **'Rate Service'**
  String get rateService;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistory;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @feedbackTags.
  ///
  /// In en, this message translates to:
  /// **'Feedback Tags'**
  String get feedbackTags;

  /// No description provided for @ratingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Rating Breakdown'**
  String get ratingBreakdown;

  /// No description provided for @cnicVerified.
  ///
  /// In en, this message translates to:
  /// **'CNIC Verified'**
  String get cnicVerified;

  /// No description provided for @requestNow.
  ///
  /// In en, this message translates to:
  /// **'Request Now'**
  String get requestNow;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @whatsTheIssue.
  ///
  /// In en, this message translates to:
  /// **'What\'s the issue? (optional)'**
  String get whatsTheIssue;

  /// No description provided for @paymentCOD.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery (COD)'**
  String get paymentCOD;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get serviceFee;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// No description provided for @estTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get estTotal;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent! 🎉'**
  String get requestSent;

  /// No description provided for @trackingWorker.
  ///
  /// In en, this message translates to:
  /// **'Track Worker Live'**
  String get trackingWorker;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
