// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WaterPulse';

  @override
  String get homeToday => 'Today';

  @override
  String get homeAddWater => 'Add Water';

  @override
  String get homeGoal => 'Goal';

  @override
  String get suggestions => 'Did you know?';

  @override
  String get suggestionText =>
      'Based on your activity, drink a bit more water 💧';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get friends => 'Friends';

  @override
  String get friendsSubtitle => 'Compare with your friends';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementsSubtitle => 'Track your streaks & badges';

  @override
  String get streakAvatar => 'Streak & avatar';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectDate => 'Selected date';

  @override
  String get hydrationTime => 'Hydration Time! 💧';

  @override
  String get hydrationBody =>
      'You are close to your daily goal! Keep drinking water.';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get days => 'days';

  @override
  String get avatarSkins => 'Avatar skins';

  @override
  String get noSkins => 'No skins yet';

  @override
  String get defaultSkinName => 'Skin';

  @override
  String get navHome => 'Home';

  @override
  String get navDatas => 'Datas';

  @override
  String get navSports => 'Sports';

  @override
  String get skinMintBreeze => 'Mint Breeze';

  @override
  String get skinOceanBlue => 'Ocean Blue';

  @override
  String get skinSunrise => 'Sunrise';

  @override
  String get guestUser => 'Guest User';

  @override
  String keepHydrating(Object username) {
    return 'Keep hydrating, $username!';
  }

  @override
  String get loginToSync => 'Log in to sync your data';

  @override
  String get login => 'Log in';

  @override
  String get signup => 'Sign up';

  @override
  String get logout => 'Log out';

  @override
  String get dailyGoalSubtitle =>
      'Adjust how much water you want to drink per day.';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersSubtitle => 'Get gentle reminders to drink water.';

  @override
  String get remindersOn => 'Reminders: On';

  @override
  String get remindersOff => 'Reminders: Off';

  @override
  String get themeSubtitle => 'Switch between Light and Dark mode.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get languageSubtitle => 'Select your preferred language.';

  @override
  String get friendsLeaderboard => 'Friends & Leaderboard';

  @override
  String get yourCode => 'Your Code:';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get pasteFriendCode => 'Paste friend code';

  @override
  String friendRequestSent(Object code) {
    return 'Friend request sent: $code';
  }

  @override
  String get add => 'Add';

  @override
  String get noFriends => 'No friends added yet.';

  @override
  String get allAchievements => 'All Achievements';

  @override
  String get noAchievements => 'No achievements yet';

  @override
  String get streakMedallions => 'Streak medallions';

  @override
  String dayStreak(Object count) {
    return '$count day streak';
  }

  @override
  String daysLeft(Object count) {
    return '$count days left';
  }

  @override
  String get won => 'Won';

  @override
  String get achGoalReached => 'You reached your daily water intake goal!';

  @override
  String get achFirstLog => 'First water log';

  @override
  String get ach500ml => '500 ml in a day';

  @override
  String get achGoal1Day => 'Complete goal 1 day in a row';

  @override
  String get achGoal7Days => 'Complete goal 7 days in a row';

  @override
  String get achGoal30Days => 'Complete goal 30 days in a row';

  @override
  String get achGoal90Days => 'Complete goal 90 days in a row';
}
