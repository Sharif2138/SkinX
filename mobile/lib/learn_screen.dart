import 'package:flutter/material.dart';

import 'widgets/skinx_header.dart';
import 'widgets/skinx_icon.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF8C9D9B);
const _softGreen = Color(0xFFEAF2E9);
const _line = Color(0xFFF3F5F2);

class LearnScreen extends StatelessWidget {
  const LearnScreen({
    super.key,
    this.onLanguageTap,
    this.onFeaturedGuideTap,
    this.onSkinChangesTap,
    this.onSeekCareTap,
    this.onAllVideosTap,
    this.onVideoTap,
    this.languageCode = 'EN',
    this.heroAsset = 'assets/person_with_albinism.png',
    this.videoAsset = 'assets/skin_care_conversation.png',
  });

  final VoidCallback? onLanguageTap;
  final VoidCallback? onFeaturedGuideTap;
  final VoidCallback? onSkinChangesTap;
  final VoidCallback? onSeekCareTap;
  final VoidCallback? onAllVideosTap;
  final VoidCallback? onVideoTap;
  final String languageCode;
  final String heroAsset;
  final String videoAsset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Tablets use two columns. Text, icons and spacing keep their sizes.
          final useTwoColumns = constraints.maxWidth >= 600;
          final featuredGuide = _FeaturedGuide(
            imageAsset: heroAsset,
            onTap: onFeaturedGuideTap,
          );
          final resources = _LearnResources(
            videoAsset: videoAsset,
            onSkinChangesTap: onSkinChangesTap,
            onSeekCareTap: onSeekCareTap,
            onAllVideosTap: onAllVideosTap,
            onVideoTap: onVideoTap,
          );

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  useTwoColumns ? 32 : 20,
                  16,
                  useTwoColumns ? 32 : 20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkinXHeader(
                      languageCode: languageCode,
                      onLanguageTap: onLanguageTap,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Learn to protect your skin',
                      style: _type(24, weight: FontWeight.w700, height: 1.14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Small steps for healthier skin.',
                      style: _type(14, color: _muted, height: 1.42),
                    ),
                    const SizedBox(height: 23),
                    if (useTwoColumns)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: featuredGuide),
                          const SizedBox(width: 24),
                          Expanded(child: resources),
                        ],
                      )
                    else ...[
                      featuredGuide,
                      const SizedBox(height: 27),
                      resources,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LearnResources extends StatelessWidget {
  const _LearnResources({
    required this.videoAsset,
    this.onSkinChangesTap,
    this.onSeekCareTap,
    this.onAllVideosTap,
    this.onVideoTap,
  });

  final String videoAsset;
  final VoidCallback? onSkinChangesTap;
  final VoidCallback? onSeekCareTap;
  final VoidCallback? onAllVideosTap;
  final VoidCallback? onVideoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Skin-health guides',
                style: _type(22, weight: FontWeight.w700, height: 1.15),
              ),
            ),
            Text(
              '2 topics',
              style: _type(11, color: _teal, weight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _GuideRow(
          symbol: SkinXIconType.search,
          title: 'Notice changes in your skin',
          subtitle: 'What to look for • 3 min read',
          category: 'SKIN CHANGES',
          onTap: onSkinChangesTap,
        ),
        Container(height: 1, color: _line),
        _GuideRow(
          symbol: SkinXIconType.heart,
          title: 'When to seek care',
          subtitle: 'Getting support • 3 min read',
          category: 'CARE & SUPPORT',
          onTap: onSeekCareTap,
        ),
        const SizedBox(height: 27),
        Row(
          children: [
            Expanded(
              child: Text(
                'Watch & learn',
                style: _type(22, weight: FontWeight.w700, height: 1.15),
              ),
            ),
            InkWell(
              onTap: onAllVideosTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'All videos',
                  style: _type(11, color: _teal, weight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _VideoCard(imageAsset: videoAsset, onTap: onVideoTap),
      ],
    );
  }
}

TextStyle _type(
  double size, {
  Color color = _ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.25,
  double tracking = 0,
}) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: tracking,
  );
}

class _FeaturedGuide extends StatelessWidget {
  const _FeaturedGuide({required this.imageAsset, this.onTap});

  final String imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imageAsset, fit: BoxFit.cover, filterQuality: FilterQuality.high),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0x10000000), Color(0xA8000000)],
                        stops: [0.25, 0.48, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    right: 15,
                    bottom: 17,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FEATURED GUIDE',
                          style: _type(9, color: const Color(0xFFD6E8D6), weight: FontWeight.w700, tracking: 0.8),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Small habits.\nStronger protection.',
                          style: _type(21, color: Colors.white, weight: FontWeight.w700, height: 1.08),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'EVERYDAY PROTECTION',
                          style: _type(10, color: _teal, weight: FontWeight.w700, tracking: 0.65),
                        ),
                      ),
                      Text('4 min read', style: _type(11, color: _muted)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Make sun protection a habit',
                          style: _type(18.5, weight: FontWeight.w700, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: _softGreen, borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: const SkinXIcon(SkinXIconType.arrowUpRight, size: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shade, covered skin and sunscreen can help protect skin with albinism.',
                    style: _type(13, color: _muted, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.category,
    this.onTap,
  });

  final SkinXIconType symbol;
  final String title;
  final String subtitle;
  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: _softGreen, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: SkinXIcon(symbol, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _type(15.5, weight: FontWeight.w600, height: 1.2)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: _type(12, color: _muted, height: 1.25)),
                  const SizedBox(height: 2),
                  Text(category, style: _type(9, color: _teal, weight: FontWeight.w700, tracking: 0.5)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const SkinXIcon(SkinXIconType.chevronRight, size: 16),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.imageAsset, this.onTap});

  final String imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 88,
                    height: 68,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(imageAsset, fit: BoxFit.cover, filterQuality: FilterQuality.high),
                        Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const SkinXIcon(SkinXIconType.play, size: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protecting your skin outdoors',
                        style: _type(15.5, weight: FontWeight.w600, height: 1.25),
                      ),
                      const SizedBox(height: 5),
                      Text('Short video • 2:40', style: _type(12, color: _muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
