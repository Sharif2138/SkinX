import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


enum SkinXDestination { learn, history, screen, ask, account }

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
    this.onNavigationTap,
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
  final ValueChanged<SkinXDestination>? onNavigationTap;
  final String languageCode;
  final String heroAsset;
  final String videoAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // All reference measurements scale from a 390 logical-pixel width.
        final s = constraints.maxWidth / 390;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 28 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        scale: s,
                        languageCode: languageCode,
                        onLanguageTap: onLanguageTap,
                      ),
                      SizedBox(height: 22 * s),
                      Text(
                        'Learn to protect your skin',
                        style: _type(s, 24, weight: FontWeight.w700, height: 1.14),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        'Small steps for healthier skin.',
                        style: _type(s, 14, color: _muted, height: 1.42),
                      ),
                      SizedBox(height: 23 * s),
                      _FeaturedGuide(
                        scale: s,
                        imageAsset: heroAsset,
                        onTap: onFeaturedGuideTap,
                      ),
                      SizedBox(height: 27 * s),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Skin-health guides',
                              style: _type(s, 22, weight: FontWeight.w700, height: 1.15),
                            ),
                          ),
                          Text(
                            '2 topics',
                            style: _type(s, 11, color: _teal, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 14 * s),
                      _GuideRow(
                        scale: s,
                        symbol: _Symbol.search,
                        title: 'Notice changes in your skin',
                        subtitle: 'What to look for • 3 min read',
                        category: 'SKIN CHANGES',
                        onTap: onSkinChangesTap,
                      ),
                      Container(height: s, color: _line),
                      _GuideRow(
                        scale: s,
                        symbol: _Symbol.heart,
                        title: 'When to seek care',
                        subtitle: 'Getting support • 3 min read',
                        category: 'CARE & SUPPORT',
                        onTap: onSeekCareTap,
                      ),
                      SizedBox(height: 27 * s),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Watch & learn',
                              style: _type(s, 22, weight: FontWeight.w700, height: 1.15),
                            ),
                          ),
                          InkWell(
                            onTap: onAllVideosTap,
                            borderRadius: BorderRadius.circular(6 * s),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 6 * s),
                              child: Text(
                                'All videos',
                                style: _type(s, 11, color: _teal, weight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * s),
                      _VideoCard(scale: s, imageAsset: videoAsset, onTap: onVideoTap),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _BottomBar(scale: s, onTap: onNavigationTap),
            ),
          ),
        );
      },
    );
  }
}

TextStyle _type(
  double scale,
  double size, {
  Color color = _ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.25,
  double tracking = 0,
}) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontSize: size * scale,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: tracking * scale,
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.scale, required this.languageCode, this.onLanguageTap});

  final double scale;
  final String languageCode;
  final VoidCallback? onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 40 * s,
      child: Row(
        children: [
          SvgPicture.asset('assets/skinx_logo.svg', width: 20 * s, height: 20 * s),
          SizedBox(width: 10 * s),
          Text('skinX', style: _type(s, 23, weight: FontWeight.w700)),
          const Spacer(),
          Semantics(
            label: 'Change language, $languageCode',
            button: true,
            child: InkWell(
              onTap: onLanguageTap,
              borderRadius: BorderRadius.circular(8 * s),
              child: SizedBox(
                height: 40 * s,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LineIcon(_Symbol.globe, size: 17 * s),
                    SizedBox(width: 6 * s),
                    Text(languageCode, style: _type(s, 12, color: _teal, weight: FontWeight.w600)),
                    SizedBox(width: 5 * s),
                    _LineIcon(_Symbol.chevronDown, size: 12 * s),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedGuide extends StatelessWidget {
  const _FeaturedGuide({required this.scale, required this.imageAsset, this.onTap});

  final double scale;
  final String imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 214 * s,
              width: double.infinity,
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
                    left: 15 * s,
                    right: 15 * s,
                    bottom: 17 * s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FEATURED GUIDE',
                          style: _type(s, 9, color: const Color(0xFFD6E8D6), weight: FontWeight.w700, tracking: 0.8),
                        ),
                        SizedBox(height: 7 * s),
                        Text(
                          'Small habits.\nStronger protection.',
                          style: _type(s, 21, color: Colors.white, weight: FontWeight.w700, height: 1.08),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15 * s, 16 * s, 15 * s, 16 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'EVERYDAY PROTECTION',
                          style: _type(s, 10, color: _teal, weight: FontWeight.w700, tracking: 0.65),
                        ),
                      ),
                      Text('4 min read', style: _type(s, 11, color: _muted)),
                    ],
                  ),
                  SizedBox(height: 9 * s),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Make sun protection a habit',
                          style: _type(s, 18.5, weight: FontWeight.w700, height: 1.2),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Container(
                        width: 28 * s,
                        height: 28 * s,
                        decoration: BoxDecoration(color: _softGreen, borderRadius: BorderRadius.circular(8 * s)),
                        alignment: Alignment.center,
                        child: _LineIcon(_Symbol.arrowUpRight, size: 17 * s),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * s),
                  Text(
                    'Shade, covered skin and sunscreen can help protect\nskin with albinism.',
                    style: _type(s, 13, color: _muted, height: 1.5),
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
    required this.scale,
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.category,
    this.onTap,
  });

  final double scale;
  final _Symbol symbol;
  final String title;
  final String subtitle;
  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10 * s),
      child: SizedBox(
        height: 72 * s,
        child: Row(
          children: [
            Container(
              width: 42 * s,
              height: 42 * s,
              decoration: BoxDecoration(color: _softGreen, borderRadius: BorderRadius.circular(12 * s)),
              alignment: Alignment.center,
              child: _LineIcon(symbol, size: 23 * s),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _type(s, 15.5, weight: FontWeight.w600, height: 1.2)),
                  SizedBox(height: 3 * s),
                  Text(subtitle, style: _type(s, 12, color: _muted, height: 1.25)),
                  SizedBox(height: 2 * s),
                  Text(category, style: _type(s, 9, color: _teal, weight: FontWeight.w700, tracking: 0.5)),
                ],
              ),
            ),
            SizedBox(width: 6 * s),
            _LineIcon(_Symbol.chevronRight, size: 16 * s),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.scale, required this.imageAsset, this.onTap});

  final double scale;
  final String imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14 * s),
        side: BorderSide(color: _line, width: 1.5 * s),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 88 * s,
          child: Padding(
            padding: EdgeInsets.all(9 * s),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8 * s),
                  child: SizedBox(
                    width: 88 * s,
                    height: 68 * s,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(imageAsset, fit: BoxFit.cover, filterQuality: FilterQuality.high),
                        Center(
                          child: Container(
                            width: 30 * s,
                            height: 30 * s,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: _LineIcon(_Symbol.play, size: 17 * s),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protecting your skin outdoors',
                        style: _type(s, 15.5, weight: FontWeight.w600, height: 1.25),
                      ),
                      SizedBox(height: 5 * s),
                      Text('Short video • 2:40', style: _type(s, 12, color: _muted)),
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.scale, this.onTap});

  final double scale;
  final ValueChanged<SkinXDestination>? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82 * s,
          child: Stack(
            children: [
              Positioned(left: 0, right: 0, top: 16 * s, child: Container(height: s, color: _line)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5 * s),
                child: Row(
                  children: [
                    _item(SkinXDestination.learn, 'Learn', _Symbol.book, s, active: true),
                    _item(SkinXDestination.history, 'History', _Symbol.history, s),
                    _item(SkinXDestination.screen, 'Screen', _Symbol.scan, s, raised: true),
                    _item(SkinXDestination.ask, 'Ask', _Symbol.chat, s),
                    _item(SkinXDestination.account, 'Account', _Symbol.account, s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    SkinXDestination destination,
    String label,
    _Symbol symbol,
    double s, {
    bool active = false,
    bool raised = false,
  }) {
    final color = active ? _teal : _muted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        child: InkWell(
          onTap: onTap == null ? null : () => onTap!(destination),
          borderRadius: BorderRadius.circular(14 * s),
          child: SizedBox(
            height: 82 * s,
            child: Column(
              children: [
                SizedBox(height: (raised ? 2 : 31) * s),
                if (raised)
                  Container(
                    width: 54 * s,
                    height: 54 * s,
                    decoration: BoxDecoration(
                      color: _teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2 * s),
                    ),
                    alignment: Alignment.center,
                    child: _LineIcon(symbol, size: 27 * s, color: Colors.white),
                  )
                else
                  Container(
                    width: 45 * s,
                    height: 28 * s,
                    decoration: BoxDecoration(
                      color: active ? _softGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(18 * s),
                    ),
                    alignment: Alignment.center,
                    child: _LineIcon(symbol, size: 24 * s, color: color),
                  ),
                SizedBox(height: (raised ? 10 : 7) * s),
                Text(label, style: _type(s, 10.5, color: color, weight: active ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


enum _Symbol { globe, chevronDown, arrowUpRight, search, heart, chevronRight, play, book, history, scan, chat, account }

class _LineIcon extends StatelessWidget {
  const _LineIcon(this.symbol, {required this.size, this.color = _teal});

  final _Symbol symbol;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LineIconPainter(symbol, color)),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  const _LineIconPainter(this.symbol, this.color);

  final _Symbol symbol;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (symbol) {
      case _Symbol.globe:
        canvas.drawCircle(const Offset(12, 12), 8.5, p);
        canvas.drawOval(const Rect.fromLTRB(8, 3.5, 16, 20.5), p);
        canvas.drawLine(const Offset(3.5, 12), const Offset(20.5, 12), p);
        break;
      case _Symbol.chevronDown:
        canvas.drawPath(Path()..moveTo(6, 9)..lineTo(12, 15)..lineTo(18, 9), p);
        break;
      case _Symbol.arrowUpRight:
        canvas.drawPath(Path()..moveTo(6, 18)..lineTo(18, 6)..moveTo(7, 6)..lineTo(18, 6)..lineTo(18, 17), p);
        break;
      case _Symbol.search:
        canvas.drawCircle(const Offset(10.5, 10.5), 6.5, p);
        canvas.drawLine(const Offset(15.3, 15.3), const Offset(20.5, 20.5), p);
        break;
      case _Symbol.heart:
        canvas.drawPath(
          Path()..moveTo(12, 20)..lineTo(4.3, 12.4)..cubicTo(-1, 7.1, 6.1, 0.8, 12, 6.6)..cubicTo(17.9, 0.8, 25, 7.1, 19.7, 12.4)..close(),
          p,
        );
        canvas.drawPath(Path()..moveTo(4, 11)..lineTo(8, 11)..lineTo(10, 8)..lineTo(12.5, 14)..lineTo(14.5, 11)..lineTo(20, 11), p);
        break;
      case _Symbol.chevronRight:
        canvas.drawPath(Path()..moveTo(9, 6)..lineTo(15, 12)..lineTo(9, 18), p);
        break;
      case _Symbol.play:
        canvas.drawPath(Path()..moveTo(8, 5)..lineTo(19, 12)..lineTo(8, 19)..close(), p);
        break;
      case _Symbol.book:
        canvas.drawPath(
          Path()..moveTo(12, 5)..cubicTo(9, 3, 5, 3, 2.5, 4)..lineTo(2.5, 19)..cubicTo(6, 18, 9, 18.5, 12, 21)..cubicTo(15, 18.5, 18, 18, 21.5, 19)..lineTo(21.5, 4)..cubicTo(19, 3, 15, 3, 12, 5)..lineTo(12, 21),
          p,
        );
        break;
      case _Symbol.history:
        canvas.drawPath(Path()..moveTo(3, 3)..lineTo(3, 8)..lineTo(8, 8), p);
        canvas.drawArc(const Rect.fromLTRB(4, 4, 21, 21), -2.45, 5.55, false, p);
        canvas.drawPath(Path()..moveTo(12.5, 8)..lineTo(12.5, 12.5)..lineTo(16, 14.5), p);
        break;
      case _Symbol.scan:
        canvas.drawPath(
          Path()..moveTo(8, 3)..lineTo(5, 3)..quadraticBezierTo(3, 3, 3, 5)..lineTo(3, 8)
            ..moveTo(16, 3)..lineTo(19, 3)..quadraticBezierTo(21, 3, 21, 5)..lineTo(21, 8)
            ..moveTo(21, 16)..lineTo(21, 19)..quadraticBezierTo(21, 21, 19, 21)..lineTo(16, 21)
            ..moveTo(8, 21)..lineTo(5, 21)..quadraticBezierTo(3, 21, 3, 19)..lineTo(3, 16)
            ..moveTo(8, 10)..lineTo(16, 10)..moveTo(8, 14)..lineTo(16, 14),
          p,
        );
        break;
      case _Symbol.chat:
        canvas.drawPath(
          Path()..moveTo(6, 19)..cubicTo(4, 17.5, 2.5, 15, 2.5, 12)..cubicTo(2.5, 6.5, 6.5, 3, 12, 3)..cubicTo(17.5, 3, 21.5, 6.5, 21.5, 12)..cubicTo(21.5, 17.5, 17.5, 21, 12, 21)..lineTo(8.5, 20.4)..lineTo(4.5, 22)..close(),
          p,
        );
        break;
      case _Symbol.account:
        canvas.drawCircle(const Offset(12, 7), 3.8, p);
        canvas.drawPath(Path()..moveTo(4, 21)..cubicTo(4.7, 16, 7.5, 13, 12, 13)..cubicTo(16.5, 13, 19.3, 16, 20, 21), p);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LineIconPainter oldDelegate) {
    return oldDelegate.symbol != symbol || oldDelegate.color != color;
  }
}
