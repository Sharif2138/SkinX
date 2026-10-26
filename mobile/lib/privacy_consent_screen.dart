import 'package:flutter/material.dart';

import 'services/app_language.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF647D78);

class _PolicySection {
  const _PolicySection(this.enTitle, this.enText, this.rwTitle, this.rwText);

  final String enTitle;
  final String enText;
  final String rwTitle;
  final String rwText;
}

const _sections = <_PolicySection>[
  _PolicySection(
    'What SkinX does',
    'SkinX is a research prototype for skin-health education and early referral support, especially for people with albinism. The screening result is not a medical diagnosis and cannot rule out skin cancer. A growing, bleeding, changing or non-healing skin area should be examined by a qualified health professional, whatever the app says.',
    'Icyo SkinX ikora',
    'SkinX ni porogaramu y’igerageza igamije gutanga amakuru ku buzima bw’uruhu no gufasha abantu kugana kwa muganga hakiri kare, cyane cyane abafite albinisme. Igisubizo cyayo si isuzuma rya muganga kandi nticyemeza ko nta kanseri y’uruhu ihari. Ahantu ku ruhu hakura, hava amaraso, hahinduka cyangwa hadakira hagomba gusuzumwa n’umuganga.',
  ),
  _PolicySection(
    'Photos and screening',
    'The app uses a selected camera or gallery photo to run its screening model on the device, whether online or offline. The current screening flow does not upload the photo to FastAPI, Groq or Supabase, and the photo is not included in saved screening history. The camera or gallery service may keep temporary copies or an original photo outside SkinX. Screen only with the permission of the person whose skin is photographed.',
    'Amafoto n’isuzuma',
    'Porogaramu ikoresha ifoto yafashwe na kamera cyangwa yatoranyijwe kugira ngo ikore isuzuma kuri telefoni, yaba ifite interineti cyangwa itayifite. Muri iki gihe, SkinX ntiyohereza iyo foto kuri FastAPI, Groq cyangwa Supabase, kandi ntibika ifoto mu mateka y’isuzuma. Kamera cyangwa ububiko bw’amafoto bishobora kuba bifite kopi y’ifoto hanze ya SkinX. Banza usabe uburenganzira bw’uwo ufotora.',
  ),
  _PolicySection(
    'Accounts and details',
    'When someone registers, Supabase Auth handles their email address and sign-in information. SkinX also stores the account name and selected account type in a profile. Guests can use the offline features without registering. Individual accounts save screening results without patient names. Community health worker accounts can save a person’s name with their screening result and date, after obtaining permission.',
    'Konti n’amakuru y’umuntu',
    'Iyo umuntu yiyandikishije, Supabase ibika imeri ye n’amakuru ajyanye no kwinjira muri konti. SkinX inabika izina rya konti n’ubwoko bwa konti. Abadafite konti bashobora gukoresha serivisi zo mu buryo butarimo interineti. Konti y’umuntu ku giti cye ibika ibisubizo nta zina ry’umurwayi. Umujyanama w’ubuzima ashobora kubika izina ry’usuzumwa, igisubizo n’itariki, amaze gusaba uburenganzira.',
  ),
  _PolicySection(
    'Local and cloud history',
    'Screening history is stored in a local SQLite database only when Save is chosen. For signed-in users, the app also tries to synchronize records with Supabase when internet is available. A failed synchronization can leave a record only on the phone until a later retry. Guest records are kept separately on that device and are not automatically moved into a new account. The local database is currently not encrypted by the app; use a protected device, especially when storing another person’s name.',
    'Amateka kuri telefoni no kuri interineti',
    'Amateka y’isuzuma abikwa mu bubiko bwa SQLite kuri telefoni iyo uhisemo Kubika. Ku bantu bafite konti, SkinX igerageza kohereza ayo makuru kuri Supabase iyo interineti ihari. Iyo kohereza binaniranye, amakuru ashobora kuguma kuri telefoni kugeza igihe bizashobokera. Amakuru yabitswe udafite konti ntabwo yimurirwa muri konti nshya mu buryo bwikora. Ububiko bwa SQLite ntibufite uburyo bwihariye bwo guhisha amakuru; koresha telefoni irinzwe, cyane cyane iyo ubika amazina y’abandi bantu.',
  ),
  _PolicySection(
    'Chat and online services',
    'Offline chat searches educational information stored inside the app. When online chat is available, questions and limited recent conversation text are sent through SkinX FastAPI to Groq to generate a reply. Do not enter names, phone numbers, addresses, patient identifiers or confidential medical details in chat. SkinX does not deliberately save chat transcripts to its Supabase screening tables, but network providers and the AI provider may process requests under their own terms and policies. Online videos open YouTube, which has its own privacy practices.',
    'Ikiganiro n’izindi serivisi zo kuri interineti',
    'Ikiganiro kidakoresha interineti gishingira ku makuru y’uburezi abitswe muri porogaramu. Iyo hari interineti, ikibazo n’igice gito cy’ikiganiro giheruka byoherezwa kuri FastAPI ya SkinX no kuri Groq kugira ngo haboneke igisubizo. Ntukandike amazina, nimero za telefoni, aderesi cyangwa amakuru y’ibanga y’umurwayi mu kiganiro. SkinX ntabwo ibika ibiganiro mu mbonerahamwe z’amateka y’isuzuma za Supabase, ariko abatanga serivisi za interineti na AI bashobora gutunganya ayo makuru hakurikijwe amategeko yabo. Amashusho afungukira kuri YouTube.',
  ),
  _PolicySection(
    'Who can access information',
    'The app is designed so signed-in users can access their own cloud screening records through Supabase Row Level Security. An account does not give a community health worker access to other workers’ records. Anyone able to open an unlocked phone may still be able to view locally saved history. These safeguards do not replace secure device handling, strong passwords and appropriate organizational access policies.',
    'Abashobora kubona amakuru',
    'Porogaramu yateguwe ku buryo umuntu winjiye muri konti areba amateka ye yo kuri Supabase gusa, hifashishijwe uburyo bwo kugenzura uburenganzira bwitwa Row Level Security. Umujyanama w’ubuzima ntashobora kureba amakuru y’abandi bajyanama kubera konti ye. Ariko umuntu ufunguye telefoni itarinzwe ashobora kubona amateka yabitsweho. Ni ngombwa kurinda telefoni n’amajambo y’ibanga.',
  ),
  _PolicySection(
    'Consent for screening other people',
    'Before photographing or saving information about another person, explain what SkinX does, that it may be wrong, what will be stored, whether records can sync online and who may see them. Obtain their informed, voluntary permission and respect refusal. A community health worker must confirm permission when saving a named record. Do not collect identifiable information during research or from minors without the relevant approved process and permissions.',
    'Uburenganzira bwo gusuzuma abandi',
    'Mbere yo gufotora cyangwa kubika amakuru y’undi muntu, musobanurire icyo SkinX ikora, ko ishobora kwibeshya, amakuru azabikwa, niba ashobora koherezwa kuri interineti n’abashobora kuyabona. Saba uburenganzira bwe abisobanukiwe kandi wemere ko ashobora kwanga. Umujyanama w’ubuzima agomba kwemeza ko yabonye uburenganzira mbere yo kubika amakuru arimo izina. Ntukusanye amakuru y’ibanga mu bushakashatsi cyangwa ay’abana hatabayeho inzira yemewe n’uburenganzira bukenewe.',
  ),
  _PolicySection(
    'Choices, correction and deletion',
    'Saving a screening result is optional. You can view and delete history records in the app. Deleting a signed-in record locally starts a cloud deletion attempt when synchronization is available; deletion may be delayed while offline or if a request fails. A person may request access, correction or deletion of personal information, and withdraw consent where applicable. The current prototype does not yet provide a complete in-app account-deletion or privacy-request workflow. Do not promise immediate removal from third-party backups.',
    'Guhitamo, gukosora no gusiba',
    'Kubika igisubizo cy’isuzuma ni amahitamo yawe. Ushobora kureba no gusiba amateka muri porogaramu. Gusiba amakuru y’umuntu ufite konti bituma porogaramu igerageza kuyasiba no kuri interineti iyo bishoboka; bishobora gutinda igihe interineti idahari. Umuntu ashobora gusaba kureba, gukosora cyangwa gusiba amakuru ye, ndetse no gukuraho uburenganzira yatanze aho biboneye. Iyi porogaramu y’igerageza ntirashyiramo uburyo bwuzuye bwo gusiba konti cyangwa gutanga ibyifuzo bijyanye n’ibanga. Gusiba amakuru ntibivuze ko amakopi yose ahita asibwa mu bubiko bw’andi masosiyete.',
  ),
  _PolicySection(
    'Storage, retention and security',
    'This prototype has not established an automatic retention period for cloud and local screening records. Records can remain until removed, the app data is cleared, or a service policy applies. Supabase and Groq may process information on servers outside Rwanda, depending on their configurations. Health data is sensitive; organizational approval, appropriate hosting arrangements, access controls, retention rules and legal review are required before handling real patient records.',
    'Ububiko, igihe amakuru amara n’umutekano',
    'Iyi porogaramu y’igerageza ntirashyiraho igihe amakuru y’isuzuma abikwa kuri telefoni no kuri interineti ahita asibirwa. Ashobora kugumaho kugeza asibwe cyangwa habayeho amategeko y’utanga serivisi. Supabase na Groq bashobora gutunganya amakuru kuri seriveri zo hanze y’u Rwanda, bitewe n’uko zateguwe. Amakuru y’ubuzima ni ay’ibanga; hakenewe uburenganzira bw’inzego zibishinzwe, uburyo bwizewe bwo kuyabika, amategeko agenga igihe abikwa no kugenzura amategeko mbere yo gukoresha amakuru y’abarwayi nyabo.',
  ),
  _PolicySection(
    'Research participation and children',
    'Using SkinX is not the same as agreeing to take part in a research study. Any study involving interviews, usability testing, medical photographs or identifiable patient data needs its own approved information sheet and consent process. An adult or an authorized guardian must provide any consent required for minors under the applicable rules. Do not treat this page as research ethics approval.',
    'Kwitabira ubushakashatsi n’abana',
    'Gukoresha SkinX ntibivuze kwemera kwitabira ubushakashatsi. Ubushakashatsi burimo ibiganiro, kugerageza porogaramu, amafoto y’uruhu cyangwa amakuru aranga umuntu busaba ibisobanuro n’uburenganzira byemejwe ukwabyo. Ku bana, hakenewe uburenganzira bw’umubyeyi cyangwa undi ubifitiye ububasha hakurikijwe amategeko. Uru rupapuro ntirusimbura uburenganzira bw’ubushakashatsi.',
  ),
  _PolicySection(
    'Updates and questions',
    'This is the privacy information for the current research prototype, updated 26 October 2026. A responsible organization, verified privacy contact, applicable retention schedule and any required data-protection notices must be finalized before public or clinical deployment. This description will need updating if SkinX adds new storage, analytics, services or data uses.',
    'Impinduka n’ibibazo',
    'Aya ni amakuru y’ibanga y’iyi porogaramu y’igerageza, yavuguruwe ku wa 26 Ukwakira 2026. Mbere yo kuyikoresha mu ruhame cyangwa kwa muganga, hagomba gushyirwaho urwego rubishinzwe, aho kubaza ibijyanye n’ibanga, igihe amakuru abikwa n’andi matangazo asabwa n’amategeko. Aya makuru azahinduka niba SkinX yongeye uburyo bwo kubika amakuru cyangwa izindi serivisi.',
  ),
];

class PrivacyConsentScreen extends StatelessWidget {
  const PrivacyConsentScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppLanguage.instance,
    builder: (context, _) {
      final rw = AppLanguage.instance.code == 'rw';
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: _ink,
          elevation: 0,
          title: Text(rw ? 'Ibanga n’uburenganzira' : 'Privacy & consent',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          top: false,
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.shield_outlined, size: 30, color: _teal),
                    const SizedBox(height: 12),
                    Text(rw ? 'Amakuru yawe ni ay’ingenzi' : 'Your information matters',
                      style: const TextStyle(fontSize: 25, height: 1.2, fontWeight: FontWeight.w700, color: _ink)),
                    const SizedBox(height: 10),
                    Text(rw
                      ? 'Menya amakuru SkinX ikoresha, aho abikwa n’uburenganzira bwawe.'
                      : 'Understand what SkinX collects, what stays on your phone, and what happens when you use online features.',
                      style: const TextStyle(fontSize: 14, height: 1.55, color: _ink)),
                  ]),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE1EAE2)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded, color: _teal),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      rw
                        ? 'Gukomeza gukoresha SkinX ntibisimbura uburenganzira bwihariye bwo kubika amakuru y’umurwayi cyangwa kwitabira ubushakashatsi.'
                        : 'Reading this page does not grant consent for research or for saving another person’s information. Those require separate permission.',
                      style: const TextStyle(color: _ink, fontSize: 13, height: 1.55),
                    )),
                  ]),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < _sections.length; i++) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE1EAE2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          alignment: Alignment.center,
                          width: 29, height: 29,
                          decoration: const BoxDecoration(color: Color(0xFFE8F0E7), shape: BoxShape.circle),
                          child: Text('${i + 1}', style: const TextStyle(color: _teal, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(rw ? _sections[i].rwTitle : _sections[i].enTitle,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink))),
                      ]),
                      const SizedBox(height: 12),
                      Text(rw ? _sections[i].rwText : _sections[i].enText,
                        style: const TextStyle(fontSize: 14, height: 1.6, color: _ink)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                Text(rw ? 'Iyi ni porogaramu y’igerageza. Ibyerekeye ibanga bigomba gusuzumwa mbere yo gukoresha amakuru nyakuri.'
                  : 'Research prototype. Privacy and consent arrangements require review before real patient data is used.',
                  style: const TextStyle(fontSize: 12, color: _muted, height: 1.55)),
              ],
            ),
          )),
        ),
      );
    },
  );
}
