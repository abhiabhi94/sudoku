/// Ten creative word riddles per language, used to earn a hint. The Hindi set
/// is authored natively (not translated). Pure Dart (no Flutter).
library;

import '../models/riddle.dart';

const List<Riddle> _englishRiddles = <Riddle>[
  Riddle(
    id: 'en-echo',
    prompt: 'I speak without a mouth and hear without ears. I have no body, '
        'but I come alive with the wind. What am I?',
    answers: ['echo'],
  ),
  Riddle(
    id: 'en-footsteps',
    prompt: 'The more you take, the more you leave behind. What am I?',
    answers: ['footsteps', 'footprints', 'steps'],
  ),
  Riddle(
    id: 'en-piano',
    prompt: "What has keys but can't open a single lock?",
    answers: ['piano', 'keyboard'],
  ),
  Riddle(
    id: 'en-clock',
    prompt: 'What has hands and a face but cannot clap or smile?',
    answers: ['clock', 'watch'],
  ),
  Riddle(
    id: 'en-bottle',
    prompt: 'What has a neck but no head, and a body but no legs?',
    answers: ['bottle'],
  ),
  Riddle(
    id: 'en-towel',
    prompt: 'The more it dries, the wetter it gets. What is it?',
    answers: ['towel'],
  ),
  Riddle(
    id: 'en-comb',
    prompt: 'What has many teeth but never bites?',
    answers: ['comb'],
  ),
  Riddle(
    id: 'en-needle',
    prompt: 'What has an eye but cannot see?',
    answers: ['needle'],
  ),
  Riddle(
    id: 'en-stamp',
    prompt: 'What travels around the world while staying in one corner?',
    answers: ['stamp', 'postage stamp'],
  ),
  Riddle(
    id: 'en-candle',
    prompt: 'The taller I am, the shorter I grow. What am I?',
    answers: ['candle'],
  ),
];

const List<Riddle> _hindiRiddles = <Riddle>[
  Riddle(
    id: 'hi-aakash',
    prompt: 'एक थाल मोती से भरा, सबके सिर पर उल्टा धरा। बताओ क्या?',
    answers: ['आकाश', 'आसमान', 'अम्बर'],
  ),
  Riddle(
    id: 'hi-jeebh',
    prompt: 'बत्तीस मेरे रखवाले, एक अकेली उनके बीच में। बताओ वह एक कौन?',
    answers: ['जीभ', 'जुबान', 'ज़बान'],
  ),
  Riddle(
    id: 'hi-machhli',
    prompt: 'पानी में रहती हूँ पर प्यास नहीं बुझाती, बिन पानी मर जाती हूँ। कौन?',
    answers: ['मछली'],
  ),
  Riddle(
    id: 'hi-ullu',
    prompt: 'दिन में सोऊँ, रात में जागूँ, बड़ी-बड़ी आँखों से देखूँ। कौन?',
    answers: ['उल्लू'],
  ),
  Riddle(
    id: 'hi-tamatar',
    prompt: 'लाल शरीर, हरी टोपी, सब्ज़ी में डालो तो स्वाद बढ़े। क्या?',
    answers: ['टमाटर'],
  ),
  Riddle(
    id: 'hi-saanp',
    prompt: 'बिन पैर के चलता हूँ, बल खाकर आगे बढ़ता हूँ। कौन?',
    answers: ['साँप', 'सांप', 'नाग'],
  ),
  Riddle(
    id: 'hi-kela',
    prompt: 'पीला कपड़ा पहनूँ, मीठा मेरा स्वाद, बंदर को हूँ प्यारा। क्या?',
    answers: ['केला'],
  ),
  Riddle(
    id: 'hi-baarish',
    prompt: 'बादल से गिरूँ, धरती को हरा कर दूँ, पर चोट किसी को न लगे। क्या?',
    answers: ['बारिश', 'वर्षा', 'पानी'],
  ),
  Riddle(
    id: 'hi-taara',
    prompt: 'रात में चाँद के संग निकलूँ, आकाश में टिमटिम करूँ। कौन?',
    answers: ['तारा', 'सितारा', 'तारे'],
  ),
  Riddle(
    id: 'hi-pyaaz',
    prompt: 'काटो तो आँसू निकलें, पर बिन मेरे पकवान अधूरा। क्या?',
    answers: ['प्याज़', 'प्याज'],
  ),
];

/// The riddle bank for a [languageCode] ('hi' for Hindi, else English).
List<Riddle> riddlesFor(String languageCode) =>
    languageCode == 'hi' ? _hindiRiddles : _englishRiddles;
