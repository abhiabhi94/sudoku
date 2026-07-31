// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'सुडोकू';

  @override
  String get appTagline => 'अंक, पर मज़े के साथ';

  @override
  String get onboardTitle1 => 'स्वागत है, पहेली मित्र!';

  @override
  String get onboardBody1 =>
      'ग्रिड इस तरह भरें कि हर पंक्ति, स्तंभ और बॉक्स में 1 से 9 तक हों। गणित नहीं, बस तर्क।';

  @override
  String get onboardTitle2 => 'तीन स्तर, तीस लेवल';

  @override
  String get onboardBody2 =>
      'शुरुआती में वार्म-अप, एडवांस्ड में कमाल और एक्सपर्ट में जलवा। हर बार नई पहेली।';

  @override
  String get onboardTitle3 => 'अटक गए? संकेत कमाएँ!';

  @override
  String get onboardBody3 =>
      'एक मज़ेदार पहेली हल करें और संकेत पाएँ। तीन ग़लतियाँ चलेंगी — बार-बार अंदाज़ा लगाया तो थोड़ा रुकना पड़ेगा।';

  @override
  String get onboardSkip => 'छोड़ें';

  @override
  String get onboardNext => 'आगे';

  @override
  String get onboardStart => 'चलो खेलें!';

  @override
  String get homePlay => 'खेलें';

  @override
  String get homeContinue => 'जारी रखें';

  @override
  String homeResumeSubtitle(String level, int percent) {
    return '$level · $percent% पूर्ण';
  }

  @override
  String get homeResumeDiscard => 'हटाएँ';

  @override
  String get homeGamesCompleted => 'पूरे किए गए खेल';

  @override
  String get homeSettings => 'सेटिंग्स';

  @override
  String get tierBeginner => 'शुरुआती';

  @override
  String get tierAdvanced => 'एडवांस्ड';

  @override
  String get tierExpert => 'एक्सपर्ट';

  @override
  String get tierBeginnerTag => 'वार्म-अप';

  @override
  String get tierAdvancedTag => 'थोड़ा ज़ोर';

  @override
  String get tierExpertTag => 'जलवा दिखाएँ';

  @override
  String levelNumber(int number) {
    return 'लेवल $number';
  }

  @override
  String get levelLocked => 'लॉक';

  @override
  String get levelNew => 'नया';

  @override
  String levelBest(String time) {
    return 'सर्वश्रेष्ठ $time';
  }

  @override
  String get levelCleared => 'पूरा';

  @override
  String gameMistakes(int count, int max) {
    return 'ग़लतियाँ $count/$max';
  }

  @override
  String get gameHint => 'संकेत';

  @override
  String get gameErase => 'मिटाएँ';

  @override
  String get gameNewPuzzle => 'नई पहेली';

  @override
  String get gameDealing => 'नई पहेली तैयार हो रही है…';

  @override
  String get gameQuitTitle => 'यह पहेली छोड़ें?';

  @override
  String get gameQuitBody => 'इस पहेली की प्रगति सहेजी नहीं जाएगी।';

  @override
  String get gameQuitStay => 'खेलते रहें';

  @override
  String get gameQuitLeave => 'छोड़ें';

  @override
  String get lockoutTitle => 'अरे, ज़रा रुकिए!';

  @override
  String get lockoutBody =>
      'यह अंदाज़ा लग रहा था। एक गहरी साँस लें और सोच-समझकर चलें…';

  @override
  String lockoutCountdown(int seconds) {
    return '$seconds सेकंड में वापस';
  }

  @override
  String get hintTitle => 'संकेत पाने के लिए हल करें';

  @override
  String get hintIntro =>
      'पहेली का उत्तर दें और हम आपके लिए एक ख़ाना भर देंगे।';

  @override
  String get hintAnswerLabel => 'आपका उत्तर';

  @override
  String get hintCheck => 'जाँचें';

  @override
  String get hintNewRiddle => 'नई पहेली';

  @override
  String get hintWrong => 'बिलकुल नहीं — फिर से कोशिश करें!';

  @override
  String get hintEarned => 'वाह! यह रहा आपका संकेत ✨';

  @override
  String hintProgress(int used) {
    return 'इस लेवल में $used संकेत इस्तेमाल हुए';
  }

  @override
  String get hintShowClue => 'थोड़ा इशारा चाहिए?';

  @override
  String get hintWhyTitle => 'यहाँ क्यों?';

  @override
  String get hintUnitRow => 'पंक्ति';

  @override
  String get hintUnitColumn => 'स्तंभ';

  @override
  String get hintUnitBox => 'बॉक्स';

  @override
  String hintWhyNaked(int digit) {
    return 'इस खाने की पंक्ति, स्तंभ और बॉक्स में $digit के अलावा बाकी सब नंबर पहले से मौजूद हैं — इसलिए यहाँ सिर्फ़ $digit ही आ सकता है।';
  }

  @override
  String hintWhyHidden(String unit, int digit) {
    return 'इस $unit में $digit किसी और खाली खाने में नहीं आ सकता — बाकी हर जगह रुकी हुई है, इसलिए यह यहीं आएगा।';
  }

  @override
  String hintWhyAdvanced(int digit) {
    return 'बोर्ड पर मौजूद सभी नंबरों को देखते हुए, इस खाने में सिर्फ़ $digit ही आ सकता है।';
  }

  @override
  String get notesScribbleHint => 'इस खाने के लिए नोट्स बनाएँ';

  @override
  String get notesUndo => 'पूर्ववत';

  @override
  String get notesClear => 'साफ़ करें';

  @override
  String get victoryTitle => 'हल हो गया!';

  @override
  String get victoryCheer => 'क्या बात है!';

  @override
  String get victoryTime => 'समय';

  @override
  String get victoryMistakes => 'ग़लतियाँ';

  @override
  String get victoryHints => 'संकेत';

  @override
  String get victoryNewBest => 'नया सर्वश्रेष्ठ समय!';

  @override
  String get victoryNext => 'अगला लेवल';

  @override
  String get victoryReplay => 'फिर से खेलें';

  @override
  String get victoryHome => 'होम';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsMusic => 'संगीत';

  @override
  String get settingsMusicSubtitle => 'हल्का पृष्ठभूमि संगीत';

  @override
  String get settingsVibration => 'कंपन';

  @override
  String get settingsVibrationSubtitle => 'हर टैप महसूस करें';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsVolume => 'आवाज़';

  @override
  String get settingsTheme => 'रूप-रंग';

  @override
  String get settingsCredits => 'संगीत श्रेय';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'उजला';

  @override
  String get themeDark => 'गहरा';

  @override
  String get creditsTitle => 'संगीत श्रेय';

  @override
  String get creditsIntro =>
      'ये ट्रैक Creative Commons Attribution लाइसेंस के तहत उपयोग किए गए हैं। कलाकारों का धन्यवाद!';

  @override
  String creditsBy(String artist) {
    return '$artist द्वारा';
  }

  @override
  String get commonBack => 'वापस';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonCancel => 'रद्द करें';
}
