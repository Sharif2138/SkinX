import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/app_language.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  static const videos = [
    (
      title: 'Understanding albinism: skin cancer prevention tips',
      creator: 'By Aga Khan University Hospital, Nairobi',
      url: 'https://www.youtube.com/watch?v=pvOkoChgQJQ',
    ),
    (
      title: 'Preventing skin cancer in people with albinism',
      creator: 'By Newzroom Afrika',
      url: 'https://www.youtube.com/watch?v=2Mn8fw3GY40',
    ),
  ];

  static Future<void> openVideo(BuildContext context, String url) async {
    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: SkinXText('Could not open YouTube.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF193B38);
    const teal = Color(0xFF14665E);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        title: const SkinXText('Watch & learn'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                const SkinXText('Videos about skin cancer and albinism',
                  style: TextStyle(color: ink, fontSize: 21, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const SkinXText('Videos open in YouTube.',
                  style: TextStyle(color: Color(0xFF647D78), fontSize: 13)),
                const SizedBox(height: 22),
                for (final video in videos) ...[
                  Material(
                    color: const Color(0xFFF5F8F5),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => openVideo(context, video.url),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F1E1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: teal, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkinXText(video.title,
                                  style: const TextStyle(color: ink, fontSize: 15,
                                    fontWeight: FontWeight.w600, height: 1.4)),
                                const SizedBox(height: 6),
                                SkinXText(video.creator,
                                  style: const TextStyle(color: Color(0xFF647D78), fontSize: 12)),
                              ],
                            )),
                            const SizedBox(width: 8),
                            const Icon(Icons.open_in_new_rounded, color: teal, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
