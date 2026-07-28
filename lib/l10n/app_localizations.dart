import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('hi'),
  ];

  /// Application title.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Numbers, but make it fun'**
  String get appTagline;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome, puzzle friend!'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Fill the grid so every row, column and box has 1 to 9. No maths, just logic.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Three tiers, thirty levels'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Warm up in Beginner, flex in Advanced, and show off in Expert. Fresh boards every time.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Earn a hint!'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'Crack a fun riddle to unlock a hint. Three slips are fine — keep guessing and we\'ll make you pause.'**
  String get onboardBody3;

  /// No description provided for @onboardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// No description provided for @onboardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardNext;

  /// No description provided for @onboardStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play!'**
  String get onboardStart;

  /// No description provided for @homePlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get homePlay;

  /// No description provided for @homeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeContinue;

  /// No description provided for @homeGamesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Games completed'**
  String get homeGamesCompleted;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @tierBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get tierBeginner;

  /// No description provided for @tierAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get tierAdvanced;

  /// No description provided for @tierExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get tierExpert;

  /// No description provided for @tierBeginnerTag.
  ///
  /// In en, this message translates to:
  /// **'Warm up'**
  String get tierBeginnerTag;

  /// No description provided for @tierAdvancedTag.
  ///
  /// In en, this message translates to:
  /// **'Flex a little'**
  String get tierAdvancedTag;

  /// No description provided for @tierExpertTag.
  ///
  /// In en, this message translates to:
  /// **'Show off'**
  String get tierExpertTag;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelNumber(int number);

  /// No description provided for @levelLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get levelLocked;

  /// No description provided for @levelNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get levelNew;

  /// No description provided for @levelBest.
  ///
  /// In en, this message translates to:
  /// **'Best {time}'**
  String levelBest(String time);

  /// No description provided for @levelCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get levelCleared;

  /// No description provided for @gameMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes {count}/{max}'**
  String gameMistakes(int count, int max);

  /// No description provided for @gameHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get gameHint;

  /// No description provided for @gameErase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get gameErase;

  /// No description provided for @gameNewPuzzle.
  ///
  /// In en, this message translates to:
  /// **'New board'**
  String get gameNewPuzzle;

  /// No description provided for @gameDealing.
  ///
  /// In en, this message translates to:
  /// **'Dealing a fresh puzzle…'**
  String get gameDealing;

  /// No description provided for @gameQuitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this puzzle?'**
  String get gameQuitTitle;

  /// No description provided for @gameQuitBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress on this board won\'t be saved.'**
  String get gameQuitBody;

  /// No description provided for @gameQuitStay.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get gameQuitStay;

  /// No description provided for @gameQuitLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get gameQuitLeave;

  /// No description provided for @lockoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Whoa, slow down!'**
  String get lockoutTitle;

  /// No description provided for @lockoutBody.
  ///
  /// In en, this message translates to:
  /// **'That looked like a guess. Take a breath and think it through…'**
  String get lockoutBody;

  /// No description provided for @lockoutCountdown.
  ///
  /// In en, this message translates to:
  /// **'Back in {seconds}s'**
  String lockoutCountdown(int seconds);

  /// No description provided for @hintTitle.
  ///
  /// In en, this message translates to:
  /// **'Solve to earn a hint'**
  String get hintTitle;

  /// No description provided for @hintIntro.
  ///
  /// In en, this message translates to:
  /// **'Answer the riddle and we\'ll fill in one square for you.'**
  String get hintIntro;

  /// No description provided for @hintAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get hintAnswerLabel;

  /// No description provided for @hintCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get hintCheck;

  /// No description provided for @hintNewRiddle.
  ///
  /// In en, this message translates to:
  /// **'New riddle'**
  String get hintNewRiddle;

  /// No description provided for @hintWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite — try again!'**
  String get hintWrong;

  /// No description provided for @hintEarned.
  ///
  /// In en, this message translates to:
  /// **'Nailed it! Here\'s your hint ✨'**
  String get hintEarned;

  /// No description provided for @hintProgress.
  ///
  /// In en, this message translates to:
  /// **'{used} hints used this level'**
  String hintProgress(int used);

  /// No description provided for @victoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Solved it!'**
  String get victoryTitle;

  /// No description provided for @victoryCheer.
  ///
  /// In en, this message translates to:
  /// **'You\'re on fire!'**
  String get victoryCheer;

  /// No description provided for @victoryTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get victoryTime;

  /// No description provided for @victoryMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get victoryMistakes;

  /// No description provided for @victoryHints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get victoryHints;

  /// No description provided for @victoryNewBest.
  ///
  /// In en, this message translates to:
  /// **'New best time!'**
  String get victoryNewBest;

  /// No description provided for @victoryNext.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get victoryNext;

  /// No description provided for @victoryReplay.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get victoryReplay;

  /// No description provided for @victoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get victoryHome;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsMusicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chill background tunes'**
  String get settingsMusicSubtitle;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Feel every tap'**
  String get settingsVibrationSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Music credits'**
  String get settingsCredits;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Music credits'**
  String get creditsTitle;

  /// No description provided for @creditsIntro.
  ///
  /// In en, this message translates to:
  /// **'These tracks are used under a Creative Commons Attribution licence. Thank you to the artists!'**
  String get creditsIntro;

  /// No description provided for @creditsBy.
  ///
  /// In en, this message translates to:
  /// **'by {artist}'**
  String creditsBy(String artist);

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;
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
      <String>['en', 'hi'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
