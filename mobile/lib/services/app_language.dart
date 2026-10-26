import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class AppLanguage extends ChangeNotifier {
  AppLanguage._();

  static final instance = AppLanguage._();
  String _code = 'en';

  String get code => _code;
  String get shortCode => _code == 'rw' ? 'RW' : 'EN';
  String get displayName => _code == 'rw' ? 'Ikinyarwanda' : 'English';

  Future<void> initialize() async {
    try {
      final database = await _database();
      final rows = await database.query('preferences', where: 'name = ?',
          whereArgs: ['language'], limit: 1);
      if (rows.isNotEmpty && rows.first['value'] == 'rw') _code = 'rw';
    } catch (_) {
      _code = 'en';
    }
    notifyListeners();
  }

  Future<Database> _database() async {
    final path = '${await getDatabasesPath()}/skinx_preferences.db';
    return openDatabase(path, version: 1,
      onCreate: (db, _) async => db.execute(
        'CREATE TABLE preferences (name TEXT PRIMARY KEY, value TEXT NOT NULL)'),
    );
  }

  Future<void> setLanguage(String language) async {
    if (language != 'en' && language != 'rw') return;
    if (_code == language) return;
    _code = language;
    notifyListeners();
    try {
      final database = await _database();
      await database.insert('preferences', {'name': 'language', 'value': language},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  static String text(String english) => instance._code == 'rw'
      ? (_kinyarwanda[english] ?? english) : english;

  static Future<void> choose(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: const Text('English'),
              trailing: instance.code == 'en' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, 'en')),
          ListTile(title: const Text('Ikinyarwanda'),
              trailing: instance.code == 'rw' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, 'rw')),
        ]),
      ),
    );
    if (chosen != null) {
      instance.setLanguage(chosen);
    }
  }

  static const Map<String, String> _kinyarwanda = {
    'Can SkinX diagnose skin cancer?': 'SkinX ishobora kwemeza kanseri y’uruhu?',
    'What should I do if a sore does not heal?': 'Nakora iki niba igisebe kidakira?',
    'How can a person with albinism protect their skin?': 'Umuntu ufite albinisme yarinda ate uruhu rwe?',
    'What are signs of skin cancer in people with albinism?': 'Ni ibihe bimenyetso bya kanseri y’uruhu ku bantu bafite albinisme?',
    'Could not open YouTube.': 'Ntibyashobotse gufungura YouTube.',
    'Internet is required to watch these videos.': 'Bisaba interineti kugira ngo urebe aya mashusho.',
    'Preventing skin cancer in people with albinism': 'Kwirinda kanseri y’uruhu ku bantu bafite albinisme',
    'Understanding albinism: skin cancer prevention tips': 'Albinisme: inama zo kwirinda kanseri y’uruhu',
    'By Newzroom Afrika': 'Byateguwe na Newzroom Afrika',
    'By Aga Khan University Hospital, Nairobi': 'Byateguwe n’Ibitaro bya Kaminuza ya Aga Khan i Nairobi',
    'Watch video': 'Reba amashusho',
    'Videos open in YouTube.': 'Amashusho afungukira kuri YouTube.',
    'Medical education videos': 'Amashusho yigisha ku buzima',
    'Videos about skin cancer and albinism': 'Amashusho kuri kanseri y’uruhu na albinisme',
    'Watch on YouTube': 'Reba kuri YouTube',
    'Skin cancer prevention in albinism': 'Kwirinda kanseri y’uruhu ku bantu bafite albinisme',
    'This answer is for education, not a diagnosis.': 'Iki gisubizo ni icyo kwigisha, si isuzuma rya muganga.',
    'The online assistant is unavailable right now.': 'Ubufasha bwo kuri interineti ntibuboneka ubu.',
    'Could not reach online chat. Here is the offline answer.': 'Ikiganiro cyo kuri interineti nticyabonetse. Dore igisubizo cyo mu bubiko.',
    'Explore common questions': 'Reba ibibazo bikunze kubazwa',
    'Ask about skin care for people with albinism.': 'Baza ku kwita ku ruhu rw’abantu bafite albinisme.',
    'Ask about albinism, skin changes, protection and care.': 'Baza ibibazo kuri albinisme, impinduka z’uruhu, kwirinda izuba no kwivuza.',
    'Skin cancer prevention for people with albinism.': 'Uko abantu bafite albinisme bakwirinda kanseri y’uruhu.',
    'Notice changes in your skin': 'Menya impinduka ku ruhu rwawe',
    'What to look for • 3 min read': 'Ibyo kwitondera • iminota 3',
    'SKIN CHANGES': 'IMPINDUKA KU RUHU',
    'When to seek care': 'Igihe cyo kugana kwa muganga',
    'Getting support • 3 min read': 'Gushaka ubufasha • iminota 3',
    'CARE & SUPPORT': 'UBUVUZI N’UBUFASHA',
    'Show password': 'Erekana ijambo ry’ibanga',
    'Hide password': 'Hisha ijambo ry’ibanga',
    'Online chat could not respond (HTTP 422).': 'Ikiganiro cyo kuri interineti nticyasubije.',
    'The request was too long for online chat.': 'Ubutumwa bwoherejwe bwari burebure cyane.',
    'Screening photos are never uploaded or saved in history. Results and dates are saved only when Save is selected. Community health worker accounts also save the patient name with permission. Individual screenings do not store a patient name. Signed-in records may sync to the account. Guest history remains on this device. Local history is not encrypted; avoid shared devices.': 'Amafoto y’isuzuma ntiyoherezwa kuri interineti kandi ntabikwa mu mateka. Ibisubizo n’amatariki bibikwa iyo uhisemo kubibika. Umujyanama w’ubuzima ashobora kubika izina ry’usuzumwa amaze kubyemererwa. Konti y’umuntu ku giti cye ntibika izina ry’usuzumwa. Amakuru y’abafite konti ashobora guhuzwa kuri interineti. Amakuru y’udafite konti abikwa kuri iyi telefoni. Amakuru abitswe muri telefoni ntabwo yashyizwe mu buryo bwo kuyahisha; irinde kuyasiga kuri telefoni ikoreshwa n’abantu benshi.',
    'Cloud history is not up to date.': 'Amakuru yo kuri interineti ntarahuzwa neza.',
    'Could not save screening history.': 'Ntibyashobotse kubika amateka y’isuzuma.',
    'Could not update password. Try again.': 'Ntibyashobotse guhindura ijambo ry’ibanga. Ongera ugerageze.',
    'This result is not a diagnosis. No photo was saved.': 'Iki gisubizo si isuzuma rya muganga. Nta foto yabitswe.',
    'Could not sign out. Check your connection and try again.': 'Ntibyashobotse gusohoka muri konti. Reba interineti wongere ugerageze.',
    'Unable to open your camera or selected photo.': 'Ntibyashobotse gufungura kamera cyangwa ifoto wahisemo.',
    'Image is too large. Use a JPEG or PNG under 12 MB.': 'Ifoto ni nini cyane. Koresha JPEG cyangwa PNG iri munsi ya MB 12.',
    'Could not open local screening history.': 'Ntibyashobotse gufungura amateka y’isuzuma yabitswe.',
    'Cloud sync unavailable.': 'Kohereza amakuru kuri interineti ntibishoboka ubu.',
    'Unnamed earlier screening': 'Isuzuma rya mbere ridafite izina',
    'Offline features are available without an account': 'Serivisi zikora nta interineti ziboneka n’iyo udafite konti',
    'Learn': 'Iga',
    'History': 'Amateka',
    'Screen': 'Suzuma',
    'Ask': 'Baza',
    'Account': 'Konti',
    'Learn to protect your skin': 'Iga kurinda uruhu rwawe',
    'Small steps for healthier skin.': 'Intambwe nto zigufasha kurinda uruhu.',
    'Skin-health guides': 'Amakuru yo kwita ku ruhu',
    '2 topics': 'Ingingo 2',
    'Videos are available in online mode.': 'Amashusho aboneka iyo hari interineti.',
    'Watch & learn': 'Reba kandi wige',
    'All videos': 'Amashusho yose',
    'FEATURED GUIDE': 'ISOMO RYATORANYIJWE',
    'Small habits.\\nStronger protection.': 'Ingeso nziza.\\nKurinda uruhu kurushaho.',
    'EVERYDAY PROTECTION': 'KURINDA URUHU BURI MUNSI',
    '4 min read': 'Iminota 4 yo gusoma',
    'Make sun protection a habit': 'Gira akamenyero ko kwirinda izuba',
    'Shade, covered skin and sunscreen can help protect skin with albinism.': 'Igicucu, imyambaro ipfuka uruhu n’amavuta arinda izuba bifasha abantu bafite albinisme.',
    'Protecting your skin outdoors': 'Kurinda uruhu igihe uri hanze',
    'Short video • 2:40': 'Akavidewo • 2:40',
    'Account type': 'Ubwoko bwa konti',
    'Account role': 'Ubwoko bwa konti',
    'Account preference': 'Byatoranyijwe ubwo wiyandikishaga',
    'Your details and account preferences.': 'Amakuru ya konti yawe.',
    'Account details': 'Amakuru ya konti',
    'Name': 'Izina',
    'Email': 'Imeri',
    'Language': 'Ururimi',
    'English': 'Icyongereza',
    'Kinyarwanda': 'Ikinyarwanda',
    'Privacy & consent': 'Ibanga n’uburenganzira',
    'Sign out': 'Sohoka',
    'Sign in': 'Injira',
    'Sign up': 'Iyandikishe',
    'Account sign-in and cloud syncing are available in online mode.': 'Kwinjira muri konti no guhuza amakuru biboneka iyo hari interineti.',
    'Welcome back': 'Murakaza neza',
    'Sign in to continue your skin-health journey.': 'Injira kugira ngo ukomeze gukoresha SkinX.',
    'Forgot password?': 'Wibagiwe ijambo ry’ibanga?',
    'Continue without an account': 'Komeza udafite konti',
    'New to SkinX?': 'Ni ubwa mbere ukoresha SkinX?',
    'Small steps for healthier skin': 'Intambwe nto zo kurinda uruhu',
    'Explore skin-health guides in Learn, even without an account.': 'Soma amasomo yo kwita ku ruhu muri Iga, n’iyo udafite konti.',
    'Create your account': 'Fungura konti yawe',
    'Start your skin-health journey with SkinX.': 'Tangira kwita ku ruhu rwawe ukoresheje SkinX.',
    'Full name': 'Amazina yose',
    'Enter your full name': 'Andika amazina yawe',
    'Enter your email address': 'Andika imeri yawe',
    'Password': 'Ijambo ry’ibanga',
    'Create a password': 'Shyiraho ijambo ry’ibanga',
    'Confirm password': 'Emeza ijambo ry’ibanga',
    'Re-enter your password': 'Ongera wandike ijambo ry’ibanga',
    'Use at least 8 characters.': 'Koresha nibura inyuguti cyangwa imibare 8.',
    'Already have an account?': 'Usanzwe ufite konti?',
    'Signing in...': 'Kwinjira...',
    'Creating account...': 'Kwiyandikisha...',
    'SkinX offline mode': 'SkinX nta interineti',
    'Continue offline without an account': 'Komeza udafite interineti',
    'Sign-in and cloud services become available when connected.': 'Kwinjira no guhuza amakuru bizashoboka igihe interineti ibonetse.',
    'Ask SkinX': 'Baza SkinX',
    'Simple answers about skin health and sun protection.': 'Ibisubizo byoroshye ku buzima bw’uruhu no kwirinda izuba.',
    'What would you like to know?': 'Ni iki ushaka kumenya?',
    'Choose a question below or type your own. Basic skin-health answers are available offline.': 'Hitamo ikibazo cyangwa wandike icyawe. Amakuru y’ibanze aboneka nta interineti.',
    'What are the warning signs of skin cancer?': 'Ni ibihe bimenyetso bishobora kwerekana kanseri y’uruhu?',
    'How do I protect my skin from the sun?': 'Narinda nte uruhu rwanjye izuba?',
    'What does a suspicious result mean?': 'Igisubizo kivuga ko bikemangwa gisobanura iki?',
    'How do I check my skin?': 'Nisuzuma nte uruhu rwanjye?',
    'Finding an answer...': 'Ndimo gushaka igisubizo...',
    'View source': 'Reba aho amakuru yavuye',
    'Ask a question...': 'Baza ikibazo...',
    'Send question': 'Ohereza ikibazo',
    'AI answers are educational. Avoid sharing personal medical details.': 'Ibisubizo bya AI ni ibyo kwigisha. Wirinde gutanga amakuru yihariye y’ubuzima bwawe.',
    'Screen a skin change': 'Suzuma impinduka ku ruhu',
    'Check a skin change, step by step.': 'Suzuma impinduka ku ruhu, intambwe ku yindi.',
    'Patient name': 'Izina ry’usuzumwa',
    'Photo': 'Ifoto',
    'Skin photo': 'Ifoto y’uruhu',
    'Ready to review': 'Biteguye gusuzumwa',
    'Check the area is clear before screening.': 'Reba ko ifoto igaragara neza mbere yo gusuzuma.',
    'This photo shows a visible change on human skin.': 'Iyi foto yerekana impinduka igaragara ku ruhu rw’umuntu.',
    'Keep the affected area in focus. SkinX cannot screen objects or ordinary photos.': 'Fata ifoto igaragaza neza uruhu rwahindutse. SkinX si iyo gusuzuma ibintu bisanzwe.',
    'Screening, not a diagnosis': 'Isuzuma ry’ibanze, si isuzuma rya muganga',
    'A health professional should assess any concerning skin change.': 'Umukozi w’ubuzima agomba gusuzuma impinduka ku ruhu ziguhangayikishije.',
    'ILLUSTRATIVE PHOTO': 'IFOTO Y’URUGERO',
    'Add a clear skin photo': 'Shyiramo ifoto y’uruhu igaragara neza',
    'Use even daylight. Keep the area centered and in focus.': 'Koresha urumuri ruhagije, kandi uruhu ushaka gusuzuma rugaragare neza.',
    'Screening history': 'Amateka y’isuzuma',
    'Find and reopen saved screenings.': 'Reba ibisubizo by’isuzuma wabikije.',
    'Any date': 'Igihe icyo ari cyo cyose',
    'Choose date': 'Hitamo itariki',
    'Saved screenings': 'Ibisubizo byabitswe',
    'SAMPLE RECORDS': 'IBISUBIZO BY’URUGERO',
    'Screening result': 'Igisubizo cy’isuzuma',
    'Suspicious': 'Birakekwaho ikibazo',
    'Less suspicious': 'Ntibikekwa cyane',
    'Cannot infer': 'Ntibishoboka gutanga igisubizo',
    'Save result': 'Bika igisubizo',
    'Result saved': 'Igisubizo cyabitswe',
    'Saving...': 'Kubika...',
    'Saved screening': 'Isuzuma ryabitswe',
    'Close': 'Funga',
    'Delete record': 'Siba iki gisubizo',
    'Later': 'Nyuma',
    'Set a new password': 'Shyiraho ijambo ry’ibanga rishya',
    'Update password': 'Hindura ijambo ry’ibanga',
    'Skin-health guide': 'Isomo ku buzima bw’uruhu',
    'Information source': 'Aho amakuru yavuye',
    'This guide is for education only. It cannot replace an examination or diagnosis from a health professional.': 'Iri somo rigenewe kwigisha gusa. Ntirisimbura isuzuma ry’umukozi w’ubuzima.',
    'Not provided': 'Nta makuru yatanzwe',
    'My screening': 'Isuzuma ryanjye',
    'Offline guest': 'Ukoresha nta konti',
    'Online AI is unavailable. Showing an offline answer.': 'AI yo kuri interineti ntiri gukora. Dore igisubizo kiboneka nta interineti.',
    'SkinX · AI-assisted skin screening\\nCapstone by Sharif Kiviiri': 'SkinX · Isuzuma ry’uruhu rifashijwe na AI\\nUmushinga wa Sharif Kiviiri',
    'No account required': 'Konti si ngombwa',
    'Guest mode': 'Ukoresha nta konti',
    'Offline mode': 'Nta interineti',
    'SkinX account': 'Konti ya SkinX',
    'Signed in': 'Winjiye',
    'Sign in (online)': 'Injira (interineti)',
    'This image has a suspicious pattern. Please seek a clinical assessment. SkinX is not a diagnosis.': 'Kuri iyi foto hagaragara ibimenyetso bikekwa. Gana umukozi w’ubuzima ngo agusuzume. SkinX si isuzuma rya muganga.',
    'This does not rule out skin cancer. Have any growing, bleeding, changing or non-healing lesion checked by a health professional.': 'Ibi ntibyemeza ko nta kanseri y’uruhu ihari. Niba ahantu ku ruhu hakura, hava amaraso, hahinduka cyangwa hatakira, gisha inama umukozi w’ubuzima.',
    'Could not screen this image. Please use a valid JPEG or PNG photo.': 'Ntibyashobotse gusuzuma iyi foto. Hitamo ifoto ya JPEG cyangwa PNG.',
    'Screening could not finish on this device. Please try again.': 'Isuzuma ntiryashoboye kurangira kuri iyi telefoni. Ongera ugerageze.',
    'This photo is too dark, too bright or has too little visible detail. Take another photo in even light.': 'Iyi foto ifite umwijima mwinshi, urumuri rukabije cyangwa ntigaragara neza. Fata indi foto mu rumuri ruhagije.',
    'Could not reach FastAPI. Check the API URL and network connection.': 'Ntibyashobotse kugera kuri FastAPI. Reba aderesi ya API n’umuyoboro wa interineti.',
    'Groq API key is missing in FastAPI.': 'Urufunguzo rwa Groq ntirwashyizwe muri FastAPI.',
    'Groq rejected the API key. Check the backend configuration.': 'Groq yanze urufunguzo rwa API. Reba uko FastAPI yateguwe.',
    'The Groq model is unavailable. Check GROQ_MODEL.': 'Model ya Groq ntiboneka. Reba GROQ_MODEL.',
    'Groq request limit reached. Try again later.': 'Wageze ku mubare ntarengwa w’ibibazo kuri Groq. Ongera ugerageze nyuma.',
    'Groq timed out. Try again.': 'Groq yatinze gusubiza. Ongera ugerageze.',
    'FastAPI cannot reach Groq.': 'FastAPI ntishobora kugera kuri Groq.',
    'FastAPI returned an empty answer.': 'FastAPI yagaruye igisubizo kirimo ubusa.',
    'Offline guidance is shown above.': 'Amakuru aboneka nta interineti yerekanwe haruguru.',
    'Source links can be opened when internet is available.': 'Imbuga z’aho amakuru yavuye zifunguka iyo hari interineti.',
    'A name is required to save a patient screening. Get permission before recording it.': 'Izina rirakenewe kugira ngo ubike isuzuma ry’umuntu. Banza usabe uburenganzira.',
    'Change photo': 'Hindura ifoto',
    'Check your email to confirm the account, then sign in.': 'Reba imeri yawe wemeze konti, hanyuma winjire.',
    'Close photo': 'Funga ifoto',
    'Could not request a reset right now. Please try again online.': 'Ntibyashobotse gusaba guhindura ijambo ry’ibanga. Ongera ugerageze ufite interineti.',
    'Enter a valid email. Password reset requires a configured online account.': 'Andika imeri yemewe. Guhindura ijambo ry’ibanga bisaba konti ifite interineti.',
    'Enter your password': 'Andika ijambo ry’ibanga',
    'Filter by date': 'Shungura hakurikijwe itariki',
    'If the account exists, check your email for reset instructions.': 'Niba konti ibaho, reba imeri yawe kugira ngo uhindure ijambo ry’ibanga.',
    'Internet is not available. You can still screen a skin photo, ask skin-health questions, learn and see saved results on this device.': 'Nta interineti ihari. Ushobora gusuzuma ifoto y’uruhu, kubaza ibibazo, kwiga no kureba ibisubizo wabikije kuri iyi telefoni.',
    'New password (at least 8 characters)': 'Ijambo ry’ibanga rishya (nibura inyuguti 8)',
    'Search patient or date': 'Shakisha izina cyangwa itariki',
    'Skin-cancer education and\nAI-assisted screening': 'Amakuru kuri kanseri y’uruhu n’isuzuma\nrifashijwe n’ubwenge buhangano',
    'Small habits.\nStronger protection.': 'Ingeso nziza.\nKurinda uruhu kurushaho.',
    'Take photo': 'Fata ifoto',
    'These are illustrative records shown for demonstration. Your saved screenings will appear here.': 'Ibi ni ibisubizo by’icyitegererezo gusa. Ibyo wabikije bizagaragara hano.',
    'Upload': 'Shyiramo ifoto',
    'View photo fullscreen': 'Reba ifoto nini',
    'You can open this reference when you are online.': 'Ushobora gufungura aho amakuru yavuye igihe ufite interineti.',
    'Individual': 'Umuntu ku giti cye',
    'Community health worker': 'Umujyanama w’ubuzima',
    'For your own skin-health care': 'Ku bw’ubuzima bw’uruhu rwawe',
    'For supporting patient screenings': 'Gufasha gusuzuma abantu batandukanye',
    'Required to save the screening': 'Ni ngombwa kugira ngo ubike igisubizo',
    'More guides': 'Andi masomo',
    'SkinX is a research screening tool, not a diagnosis. Even a less suspicious result cannot rule out skin cancer.': 'SkinX ni igikoresho cy’ubushakashatsi, si isuzuma rya muganga. N’igisubizo kidakekwa cyane nticyemeza ko nta kanseri y’uruhu ihari.',
    'Confirm permission to save the patient record.': 'Emeza ko ufite uburenganzira bwo kubika amakuru y’uyu muntu.',
    'Enter the patient name to save this screening.': 'Andika izina ry’usuzumwa kugira ngo ubike igisubizo.',
    'Could not save the result on this device.': 'Ntibyashobotse kubika igisubizo kuri iyi telefoni.',
    'I have permission to save this person’s name and screening result on this device and in my account when online.': 'Mfite uburenganzira bwo kubika izina n’igisubizo by’uyu muntu kuri iyi telefoni no muri konti yanjye iyo hari interineti.',
  };
}

class SkinXText extends StatelessWidget {
  const SkinXText(this.data, {super.key, this.style, this.textAlign,
    this.overflow, this.maxLines, this.softWrap, this.textDirection,
    this.textWidthBasis, this.textHeightBehavior, this.semanticsLabel});

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final TextDirection? textDirection;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppLanguage.instance,
    builder: (context, _) => Text(
      AppLanguage.text(data),
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      textDirection: textDirection,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      semanticsLabel: semanticsLabel,
    ),
  );
}
