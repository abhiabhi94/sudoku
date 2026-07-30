/// Fifty creative word riddles per language, used to earn a hint. Each carries
/// a [Riddle.clue] — a gentle nudge revealed only if the player asks. The Hindi
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
  Riddle(
    id: 'en-map',
    prompt: 'I have cities but no houses, mountains but no trees, and water '
        'but no fish. What am I?',
    answers: ['map'],
    clue: 'You unfold me to find your way to a place.',
  ),
  Riddle(
    id: 'en-book',
    prompt: 'I have a spine but no bones, and pages full of stories. '
        'What am I?',
    answers: ['book'],
    clue: 'You turn my pages to read a tale.',
  ),
  Riddle(
    id: 'en-shadow',
    prompt: 'I follow you around all day but vanish the moment it gets dark. '
        'What am I?',
    answers: ['shadow'],
    clue: 'The sun paints me on the ground behind you.',
  ),
  Riddle(
    id: 'en-egg',
    prompt: 'What must be broken before you can use it?',
    answers: ['egg', 'an egg'],
    clue: 'A hen lays me for your breakfast.',
  ),
  Riddle(
    id: 'en-fire',
    prompt: "I'm not alive, but I grow; I have no lungs, but I need air; "
        'I have no mouth, but water kills me. What am I?',
    answers: ['fire'],
    clue: 'I flicker orange and warm your hands.',
  ),
  Riddle(
    id: 'en-river',
    prompt: 'What has a bed but never sleeps, and a mouth but never eats?',
    answers: ['river'],
    clue: 'I flow from the hills down to the sea.',
  ),
  Riddle(
    id: 'en-sponge',
    prompt: 'What is full of holes but still holds water?',
    answers: ['sponge'],
    clue: 'You squeeze me to wash the dishes.',
  ),
  Riddle(
    id: 'en-secret',
    prompt: 'If you have me, you want to share me; but if you share me, '
        'you no longer have me. What am I?',
    answers: ['secret', 'a secret'],
    clue: 'Whisper me and I stop being one.',
  ),
  Riddle(
    id: 'en-name',
    prompt: 'What belongs to you, but is used far more by other people?',
    answers: ['name', 'your name', 'my name'],
    clue: 'People call you by it.',
  ),
  Riddle(
    id: 'en-tomorrow',
    prompt: 'What is always coming but never actually arrives?',
    answers: ['tomorrow'],
    clue: 'It is the day right after today.',
  ),
  Riddle(
    id: 'en-darkness',
    prompt: 'The more of me there is, the less you see. What am I?',
    answers: ['darkness', 'the dark', 'dark'],
    clue: 'Turn off the light and I fill the room.',
  ),
  Riddle(
    id: 'en-coin',
    prompt: 'What has a head and a tail but no body at all?',
    answers: ['coin', 'a coin'],
    clue: 'You flip me to call heads or tails.',
  ),
  Riddle(
    id: 'en-glove',
    prompt: 'What has five fingers but no bones and no flesh?',
    answers: ['glove', 'a glove'],
    clue: 'You wear me to keep a hand warm.',
  ),
  Riddle(
    id: 'en-shoe',
    prompt: 'What has a tongue but cannot taste, and a sole but no soul?',
    answers: ['shoe', 'a shoe'],
    clue: 'You lace me up before a walk.',
  ),
  Riddle(
    id: 'en-table',
    prompt: 'What has four legs but cannot walk a single step?',
    answers: ['table', 'a table'],
    clue: 'You eat your dinner on top of me.',
  ),
  Riddle(
    id: 'en-saw',
    prompt: 'What has sharp teeth and a handle, yet eats nothing at all?',
    answers: ['saw', 'a saw'],
    clue: 'A carpenter uses me to cut wood.',
  ),
  Riddle(
    id: 'en-mirror',
    prompt: 'I show you yourself, yet I am not a photo. What am I?',
    answers: ['mirror', 'a mirror'],
    clue: 'You check your face in me each morning.',
  ),
  Riddle(
    id: 'en-star',
    prompt: 'I twinkle in the night sky, and I am not the moon. What am I?',
    answers: ['star', 'a star'],
    clue: 'You might wish upon me when I shine.',
  ),
  Riddle(
    id: 'en-rainbow',
    prompt: 'I arch across the sky after the rain, wearing seven colours. '
        'What am I?',
    answers: ['rainbow', 'a rainbow'],
    clue: 'Sun plus rain paints me in the sky.',
  ),
  Riddle(
    id: 'en-umbrella',
    prompt: 'I open when it rains and close when the sky is clear. What am I?',
    answers: ['umbrella', 'an umbrella'],
    clue: 'You hold me over your head in a storm.',
  ),
  Riddle(
    id: 'en-ice',
    prompt: 'I am water turned hard and cold; leave me in the sun and I '
        'disappear. What am I?',
    answers: ['ice'],
    clue: 'You drop me into a drink to cool it.',
  ),
  Riddle(
    id: 'en-sun',
    prompt: 'I rise in the east and set in the west, giving light and warmth '
        'all day. What am I?',
    answers: ['sun', 'the sun'],
    clue: 'I am the bright star at the centre of our sky.',
  ),
  Riddle(
    id: 'en-moon',
    prompt: 'I glow at night, but the light I give is not my own. What am I?',
    answers: ['moon', 'the moon'],
    clue: 'I change from a thin sliver to a full circle.',
  ),
  Riddle(
    id: 'en-tree',
    prompt: 'I have a trunk but I am not an elephant, and leaves but I am not '
        'a book. What am I?',
    answers: ['tree', 'a tree'],
    clue: 'Birds build nests in my branches.',
  ),
  Riddle(
    id: 'en-heart',
    prompt: 'I beat all day without a drum, hidden inside your chest. '
        'What am I?',
    answers: ['heart', 'your heart'],
    clue: 'You feel me thump after you run.',
  ),
  Riddle(
    id: 'en-teeth',
    prompt: 'A row of white soldiers stands guard behind a red gate, '
        'grinding your food. What are they?',
    answers: ['teeth'],
    clue: 'A brush cleans us twice a day.',
  ),
  Riddle(
    id: 'en-eye',
    prompt: 'I can see everything in front of me, yet I can never see '
        'myself. What am I?',
    answers: ['eye', 'an eye', 'the eye'],
    clue: 'You have two of me for looking.',
  ),
  Riddle(
    id: 'en-nose',
    prompt: 'I have two holes and I smell all day, right in the middle of '
        'your face. What am I?',
    answers: ['nose', 'a nose'],
    clue: 'You use me to sniff a flower.',
  ),
  Riddle(
    id: 'en-calendar',
    prompt: 'I am full of days and months, yet I am not time itself; you hang '
        'me on a wall. What am I?',
    answers: ['calendar', 'a calendar'],
    clue: 'You flip my page at the start of a month.',
  ),
  Riddle(
    id: 'en-pencil',
    prompt: 'I grow shorter the more I am used, leaving a grey trail behind '
        'me. What am I?',
    answers: ['pencil', 'a pencil'],
    clue: 'A rubber can erase what I write.',
  ),
  Riddle(
    id: 'en-ladder',
    prompt: 'I have steps but no legs, and you climb me to reach up high. '
        'What am I?',
    answers: ['ladder', 'a ladder'],
    clue: 'You lean me on a wall to paint the ceiling.',
  ),
  Riddle(
    id: 'en-road',
    prompt: 'I have no legs of my own, yet I take you everywhere; cars run '
        'along me. What am I?',
    answers: ['road', 'a road'],
    clue: 'Cars and buses drive on top of me.',
  ),
  Riddle(
    id: 'en-boat',
    prompt: 'I float on the water and carry people across, yet I am not a '
        'fish. What am I?',
    answers: ['boat', 'a boat'],
    clue: 'You row me with oars across a lake.',
  ),
  Riddle(
    id: 'en-bridge',
    prompt: 'I join two sides across a river, yet I am not a boat. What am I?',
    answers: ['bridge', 'a bridge'],
    clue: 'You walk over me to cross the water.',
  ),
  Riddle(
    id: 'en-window',
    prompt: 'You can see right through me, yet I am not air; every house '
        'has me. What am I?',
    answers: ['window', 'a window'],
    clue: 'You open me to let in fresh air and light.',
  ),
  Riddle(
    id: 'en-key',
    prompt: 'I am small and made of metal; I fit a lock and turn to open a '
        'door. What am I?',
    answers: ['key', 'a key'],
    clue: 'You keep me on a ring in your pocket.',
  ),
  Riddle(
    id: 'en-cloud',
    prompt: 'I drift across the sky, white and fluffy, and sometimes I turn '
        'grey and bring rain. What am I?',
    answers: ['cloud', 'a cloud'],
    clue: 'Rain falls from me when I grow dark.',
  ),
  Riddle(
    id: 'en-wind',
    prompt: 'You can feel me and hear me, but you can never see me; I make '
        'the trees dance. What am I?',
    answers: ['wind', 'the wind'],
    clue: 'I blow the leaves and fly a kite.',
  ),
  Riddle(
    id: 'en-honey',
    prompt: 'I am sweet and golden, made by busy bees. What am I?',
    answers: ['honey'],
    clue: 'Bees store me in a hive.',
  ),
  Riddle(
    id: 'en-snail',
    prompt: 'I carry my house on my back and move oh-so-slowly. What am I?',
    answers: ['snail', 'a snail'],
    clue: 'I leave a slow, shiny trail in the garden.',
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
  Riddle(
    id: 'hi-chand',
    prompt: 'रात में निकलूँ, चाँदनी बिखराऊँ, कभी पूरा कभी आधा दिखलाऊँ। कौन?',
    answers: ['चाँद', 'चंद्रमा', 'चन्द्रमा'],
    clue: 'रात के आसमान में चमकता, कभी पूरा कभी आधा।',
  ),
  Riddle(
    id: 'hi-sooraj',
    prompt: 'सुबह पूरब से आऊँ, शाम पश्चिम में जाऊँ, सबको रोशनी और गर्मी दूँ। कौन?',
    answers: ['सूरज', 'सूर्य'],
    clue: 'दिन में रोशनी और गर्मी देने वाला।',
  ),
  Riddle(
    id: 'hi-hathi',
    prompt: 'चार खंभे ऊपर महल, लम्बी सूँड और बड़े दो कान। कौन?',
    answers: ['हाथी'],
    clue: 'सबसे बड़ा जानवर, लम्बी सूँड वाला।',
  ),
  Riddle(
    id: 'hi-ghadi',
    prompt: 'गोल मुँह, दो हाथ चलें, टिक-टिक कर समय बतलाएँ। क्या?',
    answers: ['घड़ी'],
    clue: 'दीवार पर लगी, समय बताती है।',
  ),
  Riddle(
    id: 'hi-kitaab',
    prompt: 'पन्ने मेरे पर पेड़ नहीं, ज्ञान भरा पर बोलूँ नहीं। क्या?',
    answers: ['किताब', 'पुस्तक'],
    clue: 'पढ़ने से ज्ञान देती है।',
  ),
  Riddle(
    id: 'hi-parchhai',
    prompt: 'दिन भर साथ चलूँ तेरे, रात होते ही छिप जाऊँ। कौन?',
    answers: ['परछाई', 'छाया', 'परछाईं'],
    clue: 'धूप में तेरे पीछे-पीछे चलती है।',
  ),
  Riddle(
    id: 'hi-anda',
    prompt: 'तोड़ोगे तभी काम आऊँ, मुर्गी मुझको रोज़ देती है। क्या?',
    answers: ['अंडा', 'अण्डा'],
    clue: 'मुर्गी देती है, तोड़कर खाते हैं।',
  ),
  Riddle(
    id: 'hi-aag',
    prompt: 'बिन जान के बढ़ती जाऊँ, हवा से जलूँ, पानी से बुझ जाऊँ। क्या?',
    answers: ['आग'],
    clue: 'जलती है, पानी डालने से बुझ जाती है।',
  ),
  Riddle(
    id: 'hi-nadi',
    prompt: 'बहती रहूँ पर पैर नहीं, मुँह है पर बोलूँ नहीं, बिस्तर है पर सोऊँ नहीं। कौन?',
    answers: ['नदी'],
    clue: 'पहाड़ से निकलकर समुद्र में मिलती है।',
  ),
  Riddle(
    id: 'hi-hawa',
    prompt: 'दिखूँ नहीं पर छू सकते, साँस में भर लो, पेड़ हिला दूँ। कौन?',
    answers: ['हवा', 'वायु'],
    clue: 'दिखती नहीं पर महसूस होती है।',
  ),
  Riddle(
    id: 'hi-badal',
    prompt: 'आसमान में तैरता रहूँ, काला होकर बरस पड़ूँ। कौन?',
    answers: ['बादल', 'मेघ'],
    clue: 'इसी से बारिश होती है।',
  ),
  Riddle(
    id: 'hi-kamal',
    prompt: 'कीचड़ में खिलूँ पर साफ़ रहूँ, पानी पर तैरता गुलाबी फूल। कौन?',
    answers: ['कमल'],
    clue: 'तालाब में खिलने वाला राष्ट्रीय फूल।',
  ),
  Riddle(
    id: 'hi-mor',
    prompt: 'रंग-बिरंगे पंख मेरे, बादल देख के नाचूँ मैं। कौन?',
    answers: ['मोर'],
    clue: 'राष्ट्रीय पक्षी, बारिश में नाचता है।',
  ),
  Riddle(
    id: 'hi-gaay',
    prompt: 'घास खाऊँ, दूध पिलाऊँ, "माँ" कहलाऊँ, पूजनीय मैं। कौन?',
    answers: ['गाय'],
    clue: 'दूध देती है, "गौ माता" कहलाती है।',
  ),
  Riddle(
    id: 'hi-chidiya',
    prompt: 'नन्ही-सी मैं फुदकूँ-चहकूँ, दाना चुगूँ, आकाश में उड़ूँ। कौन?',
    answers: ['चिड़िया', 'गौरैया'],
    clue: 'छोटी, चहचहाती और उड़ती है।',
  ),
  Riddle(
    id: 'hi-titli',
    prompt: 'रंग-बिरंगे पंख लिए, फूल-फूल पर मैं मँडराऊँ। कौन?',
    answers: ['तितली'],
    clue: 'फूलों पर उड़ने वाली रंगीन।',
  ),
  Riddle(
    id: 'hi-aam',
    prompt: 'फलों का राजा कहलाऊँ, गर्मी में मीठा रस दूँ। क्या?',
    answers: ['आम'],
    clue: 'फलों का राजा, गर्मी का मीठा फल।',
  ),
  Riddle(
    id: 'hi-seb',
    prompt: 'लाल-लाल गोल मैं, रोज़ खाओ तो डॉक्टर दूर रहे। क्या?',
    answers: ['सेब'],
    clue: 'लाल गोल फल, सेहत के लिए अच्छा।',
  ),
  Riddle(
    id: 'hi-gubbara',
    prompt: 'हवा भरो तो फूल जाऊँ, ज़्यादा भरो तो फट जाऊँ। क्या?',
    answers: ['गुब्बारा', 'ग़ुब्बारा'],
    clue: 'हवा भरने पर फूलता है।',
  ),
  Riddle(
    id: 'hi-diya',
    prompt: 'तेल पिऊँ, बाती जलाऊँ, दिवाली में घर सजाऊँ। क्या?',
    answers: ['दीया', 'दीपक'],
    clue: 'दिवाली में जलाया जाता है।',
  ),
  Riddle(
    id: 'hi-chhata',
    prompt: 'बारिश में मुझको खोलो, धूप में भी साथ निभाऊँ। क्या?',
    answers: ['छाता', 'छतरी'],
    clue: 'बारिश और धूप से बचाता है।',
  ),
  Riddle(
    id: 'hi-jalebi',
    prompt: 'गोल-गोल घुमावदार, रस में डूबी मीठी मैं। क्या?',
    answers: ['जलेबी'],
    clue: 'गोल घुमावदार रस भरी मिठाई।',
  ),
  Riddle(
    id: 'hi-ghar',
    prompt: 'ईंट-पत्थर से बनूँ, धूप-बारिश से बचाऊँ, सबको आसरा दूँ। क्या?',
    answers: ['घर', 'मकान'],
    clue: 'जहाँ परिवार साथ रहता है।',
  ),
  Riddle(
    id: 'hi-darwaza',
    prompt: 'खुलूँ और बंद होऊँ, अंदर-बाहर आने-जाने दूँ। क्या?',
    answers: ['दरवाज़ा', 'दरवाजा'],
    clue: 'घर में आने-जाने का रास्ता।',
  ),
  Riddle(
    id: 'hi-khidki',
    prompt: 'दीवार में मेरा घर, हवा और रोशनी अंदर लाऊँ। क्या?',
    answers: ['खिड़की'],
    clue: 'दीवार में बनी, हवा-रोशनी आती है।',
  ),
  Riddle(
    id: 'hi-sadak',
    prompt: 'लम्बी-चौड़ी लेटी रहूँ, गाड़ियाँ मुझ पर दौड़ें। क्या?',
    answers: ['सड़क'],
    clue: 'जिस पर गाड़ियाँ चलती हैं।',
  ),
  Riddle(
    id: 'hi-rel',
    prompt: 'पटरी पर मैं दौड़ूँ, डिब्बे जोड़, छुक-छुक करती जाऊँ। कौन?',
    answers: ['रेल', 'ट्रेन', 'रेलगाड़ी'],
    clue: 'पटरी पर छुक-छुक चलती है।',
  ),
  Riddle(
    id: 'hi-naav',
    prompt: 'पानी पर मैं तैरती रहूँ, लोगों को उस पार लगाऊँ। कौन?',
    answers: ['नाव', 'नौका'],
    clue: 'पानी पर तैरकर पार कराती है।',
  ),
  Riddle(
    id: 'hi-pankha',
    prompt: 'गर्मी में मैं घूमूँ, ठंडी-ठंडी हवा दूँ। कौन?',
    answers: ['पंखा'],
    clue: 'घूमकर हवा देता है।',
  ),
  Riddle(
    id: 'hi-darpan',
    prompt: 'मेरे सामने आओ तो, अपनी ही सूरत देख लो। कौन?',
    answers: ['दर्पण', 'शीशा', 'आईना'],
    clue: 'इसमें अपना चेहरा दिखता है।',
  ),
  Riddle(
    id: 'hi-kalam',
    prompt: 'स्याही पिऊँ, अक्षर लिखूँ, कागज़ पर मैं दौड़ूँ। कौन?',
    answers: ['कलम', 'पेन'],
    clue: 'इससे कागज़ पर लिखते हैं।',
  ),
  Riddle(
    id: 'hi-pensil',
    prompt: 'जितना घिसूँ उतनी छोटी होऊँ, लिखूँ पर रबर मिटाए। क्या?',
    answers: ['पेंसिल'],
    clue: 'लिखने की चीज़, रबर से मिट जाती है।',
  ),
  Riddle(
    id: 'hi-dant',
    prompt: 'बत्तीस सफ़ेद सिपाही खड़े, खाना चबाएँ और पीसें। कौन?',
    answers: ['दाँत', 'दांत'],
    clue: 'मुँह में सफ़ेद, खाना चबाते हैं।',
  ),
  Riddle(
    id: 'hi-aankh',
    prompt: 'दो हैं हम, सारी दुनिया देखें, पर ख़ुद को कभी न देख सकें। कौन?',
    answers: ['आँख', 'आंख', 'नेत्र'],
    clue: 'इनसे देखते हैं, चेहरे पर दो होती हैं।',
  ),
  Riddle(
    id: 'hi-naak',
    prompt: 'दो छेद मेरे, साँस भी लूँ, ख़ुशबू-बदबू पहचानूँ। कौन?',
    answers: ['नाक'],
    clue: 'इससे सूँघते और साँस लेते हैं।',
  ),
  Riddle(
    id: 'hi-kaan',
    prompt: 'दो हैं हम पर बोलें नहीं, हर आवाज़ को सुन लें हम। कौन?',
    answers: ['कान'],
    clue: 'इनसे सुनते हैं, दो होते हैं।',
  ),
  Riddle(
    id: 'hi-paani',
    prompt: 'रंग न मेरा, रूप न मेरा, फिर भी सबकी प्यास बुझाऊँ। क्या?',
    answers: ['पानी', 'जल'],
    clue: 'प्यास बुझाता है, बेरंग होता है।',
  ),
  Riddle(
    id: 'hi-namak',
    prompt: 'सफ़ेद हूँ पर चीनी नहीं, बिन मेरे खाना बेस्वाद। क्या?',
    answers: ['नमक', 'नोन'],
    clue: 'खाने में स्वाद लाता है, मीठा नहीं।',
  ),
  Riddle(
    id: 'hi-samundar',
    prompt: 'बहुत बड़ा नीला मैं, खारा पानी, लहरें उठें। कौन?',
    answers: ['समुद्र', 'सागर', 'समुंदर'],
    clue: 'बहुत बड़ा खारे पानी का भंडार।',
  ),
  Riddle(
    id: 'hi-phool',
    prompt: 'रंग-बिरंगा खिलूँ बगिया में, ख़ुशबू सबको बाँटूँ मैं। कौन?',
    answers: ['फूल', 'पुष्प'],
    clue: 'बगीचे में खिलता, ख़ुशबूदार।',
  ),
];

/// The riddle bank for a [languageCode] ('hi' for Hindi, else English).
List<Riddle> riddlesFor(String languageCode) =>
    languageCode == 'hi' ? _hindiRiddles : _englishRiddles;
