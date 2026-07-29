/// Ten creative word riddles per language, used to earn a hint. Each carries a
/// [Riddle.clue] — a gentle nudge revealed only if the player asks. The Hindi
/// set is authored natively (not translated). Pure Dart (no Flutter).
library;

import '../models/riddle.dart';

const List<Riddle> _englishRiddles = <Riddle>[
  Riddle(
    id: 'en-echo',
    prompt: 'I speak without a mouth and hear without ears. I have no body, '
        'but I come alive with the wind. What am I?',
    answers: ['echo'],
    clue: 'You hear me bounce back in a canyon or an empty hall.',
  ),
  Riddle(
    id: 'en-footsteps',
    prompt: 'The more you take, the more you leave behind. What am I?',
    answers: ['footsteps', 'footprints', 'steps'],
    clue: 'You leave a trail of these behind you on wet sand.',
  ),
  Riddle(
    id: 'en-piano',
    prompt: "What has keys but can't open a single lock?",
    answers: ['piano', 'keyboard'],
    clue: '88 black-and-white keys that make music.',
  ),
  Riddle(
    id: 'en-clock',
    prompt: 'What has hands and a face but cannot clap or smile?',
    answers: ['clock', 'watch'],
    clue: 'Its two hands point at numbers all day.',
  ),
  Riddle(
    id: 'en-bottle',
    prompt: 'What has a neck but no head, and a body but no legs?',
    answers: ['bottle'],
    clue: 'You pour water out of its neck.',
  ),
  Riddle(
    id: 'en-towel',
    prompt: 'The more it dries, the wetter it gets. What is it?',
    answers: ['towel'],
    clue: 'You reach for it right after a shower.',
  ),
  Riddle(
    id: 'en-comb',
    prompt: 'What has many teeth but never bites?',
    answers: ['comb'],
    clue: 'It runs through your hair each morning.',
  ),
  Riddle(
    id: 'en-needle',
    prompt: 'What has an eye but cannot see?',
    answers: ['needle'],
    clue: 'Thread goes through its "eye" to sew.',
  ),
  Riddle(
    id: 'en-stamp',
    prompt: 'What travels around the world while staying in one corner?',
    answers: ['stamp', 'postage stamp'],
    clue: 'You stick it on a letter before posting.',
  ),
  Riddle(
    id: 'en-candle',
    prompt: 'The taller I am, the shorter I grow. What am I?',
    answers: ['candle'],
    clue: 'Its flame melts the wax as it burns.',
  ),
];

const List<Riddle> _hindiRiddles = <Riddle>[
  Riddle(
    id: 'hi-aakash',
    prompt: 'एक थाल मोती से भरा, सबके सिर पर उल्टा धरा। बताओ क्या?',
    answers: ['आकाश', 'आसमान', 'अम्बर'],
    clue: 'ऊपर देखो — नीला, तारों से भरा।',
  ),
  Riddle(
    id: 'hi-jeebh',
    prompt: 'बत्तीस मेरे रखवाले, एक अकेली उनके बीच में। बताओ वह एक कौन?',
    answers: ['जीभ', 'जुबान', 'ज़बान'],
    clue: 'मुँह के अंदर रहती है, स्वाद बताती है।',
  ),
  Riddle(
    id: 'hi-machhli',
    prompt: 'पानी में रहती हूँ पर प्यास नहीं बुझाती, बिन पानी मर जाती हूँ। कौन?',
    answers: ['मछली'],
    clue: 'तालाब या नदी में तैरती है।',
  ),
  Riddle(
    id: 'hi-ullu',
    prompt: 'दिन में सोऊँ, रात में जागूँ, बड़ी-बड़ी आँखों से देखूँ। कौन?',
    answers: ['उल्लू'],
    clue: 'रात का पक्षी, बड़ी-बड़ी आँखें।',
  ),
  Riddle(
    id: 'hi-tamatar',
    prompt: 'लाल शरीर, हरी टोपी, सब्ज़ी में डालो तो स्वाद बढ़े। क्या?',
    answers: ['टमाटर'],
    clue: 'लाल सब्ज़ी, इससे चटनी बनती है।',
  ),
  Riddle(
    id: 'hi-saanp',
    prompt: 'बिन पैर के चलता हूँ, बल खाकर आगे बढ़ता हूँ। कौन?',
    answers: ['साँप', 'सांप', 'नाग'],
    clue: 'बिना पैर के रेंगता है, बल खाकर।',
  ),
  Riddle(
    id: 'hi-kela',
    prompt: 'पीला कपड़ा पहनूँ, मीठा मेरा स्वाद, बंदर को हूँ प्यारा। क्या?',
    answers: ['केला'],
    clue: 'पीला फल, बंदर का प्रिय।',
  ),
  Riddle(
    id: 'hi-baarish',
    prompt: 'बादल से गिरूँ, धरती को हरा कर दूँ, पर चोट किसी को न लगे। क्या?',
    answers: ['बारिश', 'वर्षा', 'पानी'],
    clue: 'बादल से बूँदें गिरती हैं।',
  ),
  Riddle(
    id: 'hi-taara',
    prompt: 'रात में चाँद के संग निकलूँ, आकाश में टिमटिम करूँ। कौन?',
    answers: ['तारा', 'सितारा', 'तारे'],
    clue: 'रात में आसमान में टिमटिमाता है।',
  ),
  Riddle(
    id: 'hi-pyaaz',
    prompt: 'काटो तो आँसू निकलें, पर बिन मेरे पकवान अधूरा। क्या?',
    answers: ['प्याज़', 'प्याज'],
    clue: 'काटने पर आँसू आते हैं।',
  ),
];

/// The riddle bank for a [languageCode] ('hi' for Hindi, else English).
List<Riddle> riddlesFor(String languageCode) =>
    languageCode == 'hi' ? _hindiRiddles : _englishRiddles;
