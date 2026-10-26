import '../services/app_language.dart';
import 'offline_guides_rw.dart';
class GuideSection {
  const GuideSection(this.heading, this.body);
  final String heading;
  final String body;
}

class OfflineGuide {
  const OfflineGuide({
    required this.id,
    required this.category,
    required this.title,
    required this.introduction,
    required this.keyPoint,
    required this.sections,
    required this.sourceName,
    required this.sourceUrl,
  });

  final String id;
  final String category;
  final String title;
  final String introduction;
  final String keyPoint;
  final List<GuideSection> sections;
  final String sourceName;
  final String sourceUrl;
}

const offlineGuides = <OfflineGuide>[
  OfflineGuide(
    id: 'sun_protection',
    category: 'Everyday protection',
    title: 'Protect your skin every day',
    introduction: 'Sun protection is important for everyone. It matters even more for people with albinism because their skin has less melanin to help protect it from ultraviolet (UV) light.',
    keyPoint: 'Use shade, protective clothing and sunscreen together. None of them works perfectly on its own.',
    sections: [
      GuideSection('Plan your time outdoors', 'Try to stay in the shade when sunlight is strongest, especially around midday. If you work or travel outdoors, plan breaks in shaded places whenever possible.'),
      GuideSection('Cover exposed skin', 'Wear a wide-brimmed hat, long sleeves and clothing with a close weave. Sunglasses with UV protection help protect your eyes. Remember your ears, neck, hands and feet.'),
      GuideSection('Use sunscreen correctly', 'Choose a broad-spectrum, water-resistant sunscreen with SPF 30 or higher. Put it on exposed skin before going out, and reapply every two hours outdoors or after sweating or swimming. Use lip balm with SPF too.'),
      GuideSection('Make it a habit', 'Keep a hat and sunscreen in a place you will remember. Children and people who work outside may need help finding practical ways to stay protected every day.'),
    ],
    sourceName: 'American Academy of Dermatology · Practice safe sun',
    sourceUrl: 'https://www.aad.org/public/everyday-care/sun-protection/shade-clothing-sunscreen/practice-safe-sun',
  ),
  OfflineGuide(
    id: 'skin_changes',
    category: 'Skin changes',
    title: 'Notice changes in your skin',
    introduction: 'A new or changing mark is worth paying attention to. Many marks are harmless, but appearance alone cannot tell you for certain what they are.',
    keyPoint: 'A sore that does not heal, grows or repeatedly bleeds should be checked by a health professional.',
    sections: [
      GuideSection('Look for changes', 'Notice any new lump or patch, a spot that grows or changes shape, or an area that becomes rough, crusted or painful. A pink or pale spot can also be important.'),
      GuideSection('Watch healing', 'If a wound is not healing normally or keeps opening and bleeding, seek medical assessment. Do not wait for an app to say it is suspicious.'),
      GuideSection('Compare over time', 'If possible, note when you first saw the spot and whether it has changed. A clear photo with a date can help explain the change to a clinician, but it cannot replace an examination.'),
      GuideSection('Ask for help', 'A local clinic can examine the area and advise whether a referral is needed. If a change worries you, ask for care even if SkinX showed Less suspicious.'),
    ],
    sourceName: 'NHS · Symptoms of non-melanoma skin cancer',
    sourceUrl: 'https://www.nhs.uk/conditions/non-melanoma-skin-cancer/symptoms/',
  ),
  OfflineGuide(
    id: 'seek_care',
    category: 'Care and support',
    title: 'When to seek medical care',
    introduction: 'SkinX can support early awareness, but it cannot diagnose or rule out skin cancer. A qualified health professional is needed to examine a concerning change.',
    keyPoint: 'Seek assessment promptly for persistent, growing, bleeding or changing skin lesions, regardless of the app result.',
    sections: [
      GuideSection('Do not ignore warning signs', 'Ask for a medical review if a spot is growing, keeps bleeding, becomes crusty, or a sore does not heal. Sudden severe bleeding, rapidly worsening symptoms or signs of infection may need urgent care.'),
      GuideSection('What to tell the clinician', 'Explain when the change began, what has changed, whether it bleeds or hurts, and how much sun exposure you have had. Share any older photos if available.'),
      GuideSection('What may happen next', 'A clinician may examine the skin, ask about symptoms or refer you to a specialist. Sometimes a small tissue sample, called a biopsy, is needed to find out what the lesion is.'),
      GuideSection('If specialist care is difficult to reach', 'Start with a nearby health centre and ask how referrals work. A health worker or local albinism support organisation may be able to help you find services.'),
    ],
    sourceName: 'NHS · Symptoms and medical help',
    sourceUrl: 'https://www.nhs.uk/conditions/non-melanoma-skin-cancer/symptoms/',
  ),
  OfflineGuide(
    id: 'self_check',
    category: 'Skin awareness',
    title: 'Check your skin at home',
    introduction: 'Knowing what your skin normally looks like can help you notice changes earlier. A self-check is useful, but it is not a substitute for a professional examination.',
    keyPoint: 'Check your whole body, including areas that are hard to see, and ask for help when you need it.',
    sections: [
      GuideSection('Choose good light', 'Stand somewhere bright enough to see your skin clearly. Use a full-length mirror and a hand mirror if you have them.'),
      GuideSection('Check every area', 'Look at your face, ears, neck, scalp, chest, stomach, back, arms, hands, legs and feet. Remember between the toes and other places that are easily missed.'),
      GuideSection('Look for what is new or different', 'Pay attention to new spots, rough patches, sores that do not heal, bleeding or growth. If you cannot easily see a place on your body, ask someone you trust to help.'),
      GuideSection('Keep simple notes', 'Write down a date or take a clear photo of a concerning spot. Do not wait for your next check if you notice a warning sign. Speak with a health professional.'),
    ],
    sourceName: 'American Academy of Dermatology · Skin self-exam',
    sourceUrl: 'https://www.aad.org/public/diseases/skin-cancer/check-skin',
  ),
  OfflineGuide(
    id: 'lesion_types',
    category: 'Understanding skin cancer',
    title: 'Understand common skin lesions',
    introduction: 'Different skin conditions can look alike. Learning the names can help you follow a conversation with a clinician, but only an assessment can identify the cause of a spot.',
    keyPoint: 'A mark does not have to be dark to be important. Skin cancers in people with albinism may appear pink, pale or red.',
    sections: [
      GuideSection('Actinic keratosis (AK)', 'AK is a rough, sun-damaged patch that is considered precancerous. Some AKs can develop into squamous cell carcinoma. A clinician should assess suspicious patches.'),
      GuideSection('Squamous cell carcinoma (SCC)', 'SCC is a type of skin cancer. It may appear as a growing bump, crusted spot or sore that does not heal. It needs medical assessment and treatment.'),
      GuideSection('Basal cell carcinoma (BCC)', 'BCC is another type of skin cancer. It may look like a shiny bump, a pink patch or a sore that bleeds or does not heal.'),
      GuideSection('Melanoma and harmless lesions', 'Melanoma is a serious skin cancer, but many moles and other marks are harmless. You cannot reliably separate them from a photograph alone. Ask a clinician about any concerning change.'),
    ],
    sourceName: 'National Cancer Institute · Skin cancer treatment',
    sourceUrl: 'https://www.cancer.gov/types/skin/patient/skin-treatment-pdq',
  ),
  OfflineGuide(
    id: 'using_skinx',
    category: 'Using SkinX',
    title: 'Understand your screening result',
    introduction: 'SkinX looks for image patterns linked to its target group. It is a research screening tool, not a doctor or a cancer diagnosis.',
    keyPoint: 'Less suspicious never means cancer-free. If a spot concerns you, seek medical assessment whatever SkinX says.',
    sections: [
      GuideSection('Before you take a photo', 'Use a clear photo of the skin change, in good natural light when possible. Keep the area visible and avoid filters. Do not photograph unrelated objects for medical screening.'),
      GuideSection('Suspicious', 'The model found image patterns that may need attention. This is not proof of cancer. Arrange an assessment with a health professional.'),
      GuideSection('Less suspicious', 'The model did not flag the image at its fixed screening threshold. It can still miss skin cancer, so seek care for persistent, changing or bleeding lesions.'),
      GuideSection('Cannot infer', 'SkinX could not process the image, for example because it was invalid or unsuitable for technical reasons. Try another clear photo. This does not tell you whether a lesion is safe.'),
      GuideSection('Privacy offline', 'You can screen without internet. Saved screening history stays on the device. Only keep results you are comfortable storing, especially on a shared phone.'),
    ],
    sourceName: 'SkinX · Screening model information',
    sourceUrl: '',
  ),
  OfflineGuide(
    id: 'sunburn',
    category: 'Sun care',
    title: 'What to do after sunburn',
    introduction: 'Sunburn is a sign that your skin has been damaged by ultraviolet light. Even mild sunburn means your skin needs protection from more exposure.',
    keyPoint: 'Move out of the sun, cool your skin gently and get medical help for severe symptoms.',
    sections: [
      GuideSection('Move into shade', 'Stay out of direct sunlight while your skin recovers. Wear loose, protective clothing when you must go outside.'),
      GuideSection('Soothe your skin', 'Use a cool, damp cloth or cool shower. Drink water. Avoid scratching or peeling the skin. Ask a pharmacist or clinician about a suitable gentle moisturiser if needed.'),
      GuideSection('Know when to get help', 'Seek medical advice for large blisters, severe pain, fever, dizziness, confusion, dehydration or if a child has a significant sunburn.'),
      GuideSection('Protect yourself next time', 'Plan shade, clothing and sunscreen together. Avoid further burning, even when the skin seems to be healing.'),
    ],
    sourceName: 'American Academy of Dermatology · Sun protection guidance',
    sourceUrl: 'https://www.aad.org/public/everyday-care/sun-protection/shade-clothing-sunscreen/practice-safe-sun',
  ),
];

OfflineGuide? offlineGuideById(String id) {
  for (final guide in AppLanguage.instance.code == 'rw' ? offlineGuidesRw : offlineGuides) {
    if (guide.id == id) return guide;
  }
  return null;
}
