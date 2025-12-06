import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WaterPulse'**
  String get appName;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeAddWater.
  ///
  /// In en, this message translates to:
  /// **'Add Water'**
  String get homeAddWater;

  /// No description provided for @homeGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get homeGoal;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get suggestions;

  /// No description provided for @suggestionText.
  ///
  /// In en, this message translates to:
  /// **'Based on your activity, drink a bit more water 💧'**
  String get suggestionText;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @friendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare with your friends'**
  String get friendsSubtitle;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your streaks & badges'**
  String get achievementsSubtitle;

  /// No description provided for @streakAvatar.
  ///
  /// In en, this message translates to:
  /// **'Streak & avatar'**
  String get streakAvatar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Selected date'**
  String get selectDate;

  /// No description provided for @hydrationTime.
  ///
  /// In en, this message translates to:
  /// **'Hydration Time! 💧'**
  String get hydrationTime;

  /// No description provided for @hydrationBody.
  ///
  /// In en, this message translates to:
  /// **'You are close to your daily goal! Keep drinking water.'**
  String get hydrationBody;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @avatarSkins.
  ///
  /// In en, this message translates to:
  /// **'Avatar skins'**
  String get avatarSkins;

  /// No description provided for @noSkins.
  ///
  /// In en, this message translates to:
  /// **'No skins yet'**
  String get noSkins;

  /// No description provided for @defaultSkinName.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get defaultSkinName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDatas.
  ///
  /// In en, this message translates to:
  /// **'Datas'**
  String get navDatas;

  /// No description provided for @navSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get navSports;

  /// No description provided for @skinMintBreeze.
  ///
  /// In en, this message translates to:
  /// **'Mint Breeze'**
  String get skinMintBreeze;

  /// No description provided for @skinOceanBlue.
  ///
  /// In en, this message translates to:
  /// **'Ocean Blue'**
  String get skinOceanBlue;

  /// No description provided for @skinSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get skinSunrise;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @keepHydrating.
  ///
  /// In en, this message translates to:
  /// **'Keep hydrating, {username}!'**
  String keepHydrating(Object username);

  /// No description provided for @loginToSync.
  ///
  /// In en, this message translates to:
  /// **'Log in to sync your data'**
  String get loginToSync;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @dailyGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust how much water you want to drink per day.'**
  String get dailyGoalSubtitle;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get gentle reminders to drink water.'**
  String get remindersSubtitle;

  /// No description provided for @remindersOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders: On'**
  String get remindersOn;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders: Off'**
  String get remindersOff;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between Light and Dark mode.'**
  String get themeSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language.'**
  String get languageSubtitle;

  /// No description provided for @friendsLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Friends & Leaderboard'**
  String get friendsLeaderboard;

  /// No description provided for @yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your Code:'**
  String get yourCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @pasteFriendCode.
  ///
  /// In en, this message translates to:
  /// **'Paste friend code'**
  String get pasteFriendCode;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent: {code}'**
  String friendRequestSent(Object code);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends added yet.'**
  String get noFriends;

  /// No description provided for @allAchievements.
  ///
  /// In en, this message translates to:
  /// **'All Achievements'**
  String get allAchievements;

  /// No description provided for @noAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get noAchievements;

  /// No description provided for @streakMedallions.
  ///
  /// In en, this message translates to:
  /// **'Streak medallions'**
  String get streakMedallions;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(Object count);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(Object count);

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @achGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Hydration High Five! ✋'**
  String get achGoalReached;

  /// No description provided for @achFirstLog.
  ///
  /// In en, this message translates to:
  /// **'First Splash 💦'**
  String get achFirstLog;

  /// No description provided for @ach500ml.
  ///
  /// In en, this message translates to:
  /// **'Half Liter Hero 🦸'**
  String get ach500ml;

  /// No description provided for @achGoal1Day.
  ///
  /// In en, this message translates to:
  /// **'One Day Wonder 🌟'**
  String get achGoal1Day;

  /// No description provided for @achGoal7Days.
  ///
  /// In en, this message translates to:
  /// **'Weekly Warrior ⚔️'**
  String get achGoal7Days;

  /// No description provided for @achGoal30Days.
  ///
  /// In en, this message translates to:
  /// **'Monthly Master 🏆'**
  String get achGoal30Days;

  /// No description provided for @achGoal90Days.
  ///
  /// In en, this message translates to:
  /// **'Quarterly King 👑'**
  String get achGoal90Days;

  /// No description provided for @achEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird 🐦'**
  String get achEarlyBird;

  /// No description provided for @achNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night Owl 🦉'**
  String get achNightOwl;

  /// No description provided for @achWeekendWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior 🏖️'**
  String get achWeekendWarrior;

  /// No description provided for @achMarathon.
  ///
  /// In en, this message translates to:
  /// **'Camel Mode 🐪'**
  String get achMarathon;

  /// No description provided for @achFirstLogDesc.
  ///
  /// In en, this message translates to:
  /// **'Log your first glass of water'**
  String get achFirstLogDesc;

  /// No description provided for @ach500mlDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink 500ml in a single day'**
  String get ach500mlDesc;

  /// No description provided for @achGoalReachedDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach your daily hydration goal'**
  String get achGoalReachedDesc;

  /// No description provided for @achGoal1DayDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit your goal for 1 day'**
  String get achGoal1DayDesc;

  /// No description provided for @achGoal7DaysDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit your goal for 7 days straight'**
  String get achGoal7DaysDesc;

  /// No description provided for @achGoal30DaysDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit your goal for 30 days straight'**
  String get achGoal30DaysDesc;

  /// No description provided for @achGoal90DaysDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit your goal for 90 days straight'**
  String get achGoal90DaysDesc;

  /// No description provided for @achEarlyBirdDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink water before 8:00 AM'**
  String get achEarlyBirdDesc;

  /// No description provided for @achNightOwlDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink water after 10:00 PM'**
  String get achNightOwlDesc;

  /// No description provided for @achWeekendWarriorDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach your goal on Saturday & Sunday'**
  String get achWeekendWarriorDesc;

  /// No description provided for @achMarathonDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink 3 Liters in a single day'**
  String get achMarathonDesc;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
