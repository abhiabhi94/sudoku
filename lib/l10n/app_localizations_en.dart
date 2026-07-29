// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get appTagline => 'Numbers, but make it fun';

  @override
  String get onboardTitle1 => 'Welcome, puzzle friend!';

  @override
  String get onboardBody1 =>
      'Fill the grid so every row, column and box has 1 to 9. No maths, just logic.';

  @override
  String get onboardTitle2 => 'Three tiers, thirty levels';

  @override
  String get onboardBody2 =>
      'Warm up in Beginner, flex in Advanced, and show off in Expert. Fresh boards every time.';

  @override
  String get onboardTitle3 => 'Stuck? Earn a hint!';

  @override
  String get onboardBody3 =>
      'Crack a fun riddle to unlock a hint. Three slips are fine — keep guessing and we\'ll make you pause.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardNext => 'Next';

  @override
  String get onboardStart => 'Let\'s play!';

  @override
  String get homePlay => 'Play';

  @override
  String get homeContinue => 'Continue';

  @override
  String homeResumeSubtitle(String level, int percent) {
    return '$level · $percent% done';
  }

  @override
  String get homeResumeDiscard => 'Discard';

  @override
  String get homeGamesCompleted => 'Games completed';

  @override
  String get homeSettings => 'Settings';

  @override
  String get tierBeginner => 'Beginner';

  @override
  String get tierAdvanced => 'Advanced';

  @override
  String get tierExpert => 'Expert';

  @override
  String get tierBeginnerTag => 'Warm up';

  @override
  String get tierAdvancedTag => 'Flex a little';

  @override
  String get tierExpertTag => 'Show off';

  @override
  String levelNumber(int number) {
    return 'Level $number';
  }

  @override
  String get levelLocked => 'Locked';

  @override
  String get levelNew => 'New';

  @override
  String levelBest(String time) {
    return 'Best $time';
  }

  @override
  String get levelCleared => 'Cleared';

  @override
  String gameMistakes(int count, int max) {
    return 'Mistakes $count/$max';
  }

  @override
  String get gameHint => 'Hint';

  @override
  String get gameErase => 'Erase';

  @override
  String get gameNewPuzzle => 'New board';

  @override
  String get gameDealing => 'Dealing a fresh puzzle…';

  @override
  String get gameQuitTitle => 'Leave this puzzle?';

  @override
  String get gameQuitBody => 'Your progress on this board won\'t be saved.';

  @override
  String get gameQuitStay => 'Keep playing';

  @override
  String get gameQuitLeave => 'Leave';

  @override
  String get lockoutTitle => 'Whoa, slow down!';

  @override
  String get lockoutBody =>
      'That looked like a guess. Take a breath and think it through…';

  @override
  String lockoutCountdown(int seconds) {
    return 'Back in ${seconds}s';
  }

  @override
  String get hintTitle => 'Solve to earn a hint';

  @override
  String get hintIntro =>
      'Answer the riddle and we\'ll fill in one square for you.';

  @override
  String get hintAnswerLabel => 'Your answer';

  @override
  String get hintCheck => 'Check';

  @override
  String get hintNewRiddle => 'New riddle';

  @override
  String get hintWrong => 'Not quite — try again!';

  @override
  String get hintEarned => 'Nailed it! Here\'s your hint ✨';

  @override
  String hintProgress(int used) {
    return '$used hints used this level';
  }

  @override
  String get hintShowClue => 'Need a clue?';

  @override
  String get hintWhyTitle => 'Why here?';

  @override
  String get hintUnitRow => 'row';

  @override
  String get hintUnitColumn => 'column';

  @override
  String get hintUnitBox => 'box';

  @override
  String hintWhyNaked(int digit) {
    return 'This cell\'s row, column and box already use every number except $digit — so $digit is the only one that fits.';
  }

  @override
  String hintWhyHidden(String unit, int digit) {
    return 'In this $unit, $digit can\'t go in any other empty cell — every other spot is blocked, so it belongs here.';
  }

  @override
  String hintWhyAdvanced(int digit) {
    return 'Reading all the numbers already on the board, $digit is the only value this cell can take.';
  }

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesTooltip => 'Level notes';

  @override
  String get notesPlaceholder =>
      'Jot anything — candidates, reasoning, reminders…';

  @override
  String get notesSave => 'Save';

  @override
  String get notesTabText => 'Text';

  @override
  String get notesTabDraw => 'Draw';

  @override
  String get notesUndo => 'Undo';

  @override
  String get notesClear => 'Clear';

  @override
  String get victoryTitle => 'Solved it!';

  @override
  String get victoryCheer => 'You\'re on fire!';

  @override
  String get victoryTime => 'Time';

  @override
  String get victoryMistakes => 'Mistakes';

  @override
  String get victoryHints => 'Hints';

  @override
  String get victoryNewBest => 'New best time!';

  @override
  String get victoryNext => 'Next level';

  @override
  String get victoryReplay => 'Play again';

  @override
  String get victoryHome => 'Home';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsMusicSubtitle => 'Chill background tunes';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationSubtitle => 'Feel every tap';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsCredits => 'Music credits';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get creditsTitle => 'Music credits';

  @override
  String get creditsIntro =>
      'These tracks are used under a Creative Commons Attribution licence. Thank you to the artists!';

  @override
  String creditsBy(String artist) {
    return 'by $artist';
  }

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';
}
