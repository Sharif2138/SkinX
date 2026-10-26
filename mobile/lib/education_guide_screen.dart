import 'services/app_language.dart';
import 'widgets/skinx_feedback.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/offline_guides.dart';
import 'data/offline_guides_rw.dart';
import 'services/connectivity_service.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF647D78);

class EducationGuideScreen extends StatelessWidget {
  const EducationGuideScreen({super.key, required this.guide});

  final OfflineGuide guide;

  Future<void> _openSource(BuildContext context) async {
    if (guide.sourceUrl.isEmpty) return;
    if (!ConnectivityService.instance.online) {
      SkinXNotice.show(context, 'You can open this reference when you are online.', error: true);
      return;
    }
    final uri = Uri.parse(guide.sourceUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppLanguage.instance,
    builder: (context, _) => _buildPage(context, offlineGuideById(guide.id) ?? guide),
  );

  Widget _buildPage(BuildContext context, OfflineGuide guide) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const SkinXText('Skin-health guide', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600,
        )),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkinXText(guide.category.toUpperCase(), style: const TextStyle(
                        fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w700,
                        color: _teal,
                      )),
                      const SizedBox(height: 10),
                      SkinXText(guide.title, style: const TextStyle(
                        fontSize: 26, height: 1.15, fontWeight: FontWeight.w700,
                        color: _ink,
                      )),
                      const SizedBox(height: 14),
                      SkinXText(guide.introduction, style: const TextStyle(
                        fontSize: 14.5, height: 1.6, color: _ink,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: _teal, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: SkinXText(guide.keyPoint, style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      height: 1.5, color: _ink,
                    ))),
                  ],
                ),
                const SizedBox(height: 24),
                for (var index = 0; index < guide.sections.length; index++) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF8),
                      border: Border.all(color: const Color(0xFFE7EDE8)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0EEE2), shape: BoxShape.circle,
                          ),
                          child: SkinXText('${index + 1}', style: const TextStyle(
                            fontSize: 13, color: _teal, fontWeight: FontWeight.w700,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkinXText(guide.sections[index].heading, style: const TextStyle(
                              fontSize: 16, color: _ink, fontWeight: FontWeight.w700,
                            )),
                            const SizedBox(height: 8),
                            SkinXText(guide.sections[index].body, style: const TextStyle(
                              fontSize: 14, height: 1.6, color: _ink,
                            )),
                          ],
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 14),
                SkinXText('Information source', style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: _muted,
                )),
                const SizedBox(height: 8),
                if (guide.sourceUrl.isEmpty)
                  SkinXText(guide.sourceName, style: const TextStyle(color: _ink, fontSize: 13))
                else
                  InkWell(
                    onTap: () => _openSource(context),
                    child: Row(children: [
                      Expanded(child: SkinXText(guide.sourceName, style: const TextStyle(
                        color: _teal, fontWeight: FontWeight.w600, fontSize: 13,
                      ))),
                      const Icon(Icons.open_in_new, size: 17, color: _teal),
                    ]),
                  ),
                const SizedBox(height: 24),
                SkinXText(AppLanguage.instance.code == 'rw' ? 'Andi masomo' : 'More guides',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _ink)),
                const SizedBox(height: 8),
                for (final item in (AppLanguage.instance.code == 'rw' ? offlineGuidesRw : offlineGuides))
                  if (item.id != guide.id)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: SkinXText(item.title, style: const TextStyle(color: _teal)),
                      trailing: const Icon(Icons.chevron_right, color: _teal),
                      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                        builder: (_) => EducationGuideScreen(guide: item))),
                    ),
                const SizedBox(height: 24),
                const SkinXText(
                  'This guide is for education only. It cannot replace an examination or diagnosis from a health professional.',
                  style: TextStyle(color: _muted, height: 1.5, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
