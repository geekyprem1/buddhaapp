import 'package:core/core.dart';

StaticPage? fallbackStaticPage(String slug) {
  switch (slug) {
    case StaticPageSlugs.about:
      return const StaticPage(
        slug: StaticPageSlugs.about,
        title: LocalisedText(
          en: 'About Us',
          hi: 'हमारे बारे में',
          mr: 'आमच्याबद्दल',
        ),
        body: LocalisedText(
          en: 'Dhamma Path brings Buddhist wallpapers, ringtones, songs, '
              'meditation and daily prarthana into one respectful app.',
          hi: 'धम्म पथ बौद्ध वॉलपेपर, रिंगटोन, गीत, ध्यान और दैनिक प्रार्थना '
              'को एक सम्मानजनक ऐप में लाता है।',
          mr: 'धम्म पथ बौद्ध वॉलपेपर, रिंगटोन, गाणी, ध्यान आणि दैनिक प्रार्थना '
              'एका सन्माननीय अॅपमध्ये आणतो.',
        ),
      );
    case StaticPageSlugs.privacy:
      return const StaticPage(
        slug: StaticPageSlugs.privacy,
        title: LocalisedText(
          en: 'Privacy Policy',
          hi: 'गोपनीयता नीति',
          mr: 'गोपनीयता धोरण',
        ),
        body: LocalisedText(
          en: 'We store only what is needed to run your account: name, phone '
              'or email, language, selected teachers and alarms. Status photos '
              'stay on this device unless you later opt into cloud backup.',
          hi: 'हम केवल खाता चलाने के लिए ज़रूरी जानकारी रखते हैं: नाम, फ़ोन '
              'या ईमेल, भाषा, चुने हुए गुरु और अलार्म। स्टेटस फ़ोटो इस डिवाइस '
              'पर रहती है जब तक आप क्लाउड बैकअप न चुनें।',
          mr: 'आम्ही खाते चालवण्यासाठी लागणारी माहिती ठेवतो: नाव, फोन किंवा '
              'ईमेल, भाषा, निवडलेले गुरू आणि अलार्म. स्टेटस फोटो या डिव्हाइसवर '
              'राहतो जोपर्यंत तुम्ही क्लाउड बॅकअप निवडत नाही.',
        ),
      );
    case StaticPageSlugs.terms:
      return const StaticPage(
        slug: StaticPageSlugs.terms,
        title: LocalisedText(
          en: 'Terms & Conditions',
          hi: 'नियम और शर्तें',
          mr: 'नियम आणि अटी',
        ),
        body: LocalisedText(
          en: 'Use Dhamma Path respectfully. Content is for personal devotion. '
              'Do not redistribute licensed artwork as your own.',
          hi: 'धम्म पथ का सम्मान के साथ उपयोग करें। सामग्री व्यक्तिगत भक्ति '
              'के लिए है। लाइसेंसशुदा कला को अपनी बताकर न बाँटें।',
          mr: 'धम्म पथाचा आदराने वापर करा. आशय वैयक्तिक भक्तीसाठी आहे. '
              'परवानाधारक कला स्वतःची म्हणून वापरू नका.',
        ),
      );
    case StaticPageSlugs.contact:
      return const StaticPage(
        slug: StaticPageSlugs.contact,
        title: LocalisedText(en: 'Contact', hi: 'संपर्क', mr: 'संपर्क'),
        body: LocalisedText(
          en: 'Use Contact Us in Profile to send us a message.',
          hi: 'संदेश भेजने के लिए प्रोफ़ाइल में संपर्क करें का उपयोग करें।',
          mr: 'संदेश पाठवण्यासाठी प्रोफाइलमधील संपर्क वापरा.',
        ),
      );
    case StaticPageSlugs.help:
      return const StaticPage(
        slug: StaticPageSlugs.help,
        title: LocalisedText(en: 'Help', hi: 'सहायता', mr: 'मदत'),
        body: LocalisedText(
          en: 'Daily Prarthana uses an on-device alarm. Allow exact alarms '
              'if Android asks. Ringtones need Write Settings permission.',
          hi: 'दैनिक प्रार्थना फ़ोन पर अलार्म से चलती है। रिंगटोन के लिए '
              'Write Settings अनुमति चाहिए।',
          mr: 'दैनिक प्रार्थना फोनवरील अलार्मने वाजते. रिंगटोनसाठी '
              'Write Settings परवानगी लागते.',
        ),
      );
    default:
      return null;
  }
}
