import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.statusText = 'Getting ready...'});

  final String statusText;

  // Your startup logic decides when to leave this screen.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight < 360) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _Brand(),
                          const SizedBox(height: 32),
                          _LoadingStatus(text: statusText),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  const Align(alignment: Alignment(0, -0.24), child: _Brand()),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 52,
                    child: _LoadingStatus(text: statusText),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/skinx_logo.svg', width: 64, height: 64),
          const SizedBox(height: 24),
          const Text(
            'SkinX',
            style: TextStyle(fontFamily: 'Roboto', fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF193B38), height: 1.2),
          ),
          const SizedBox(height: 10),
          const Text(
            'Skin-cancer education and\nAI-assisted screening',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Color(0xFF647D78), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _LoadingStatus extends StatelessWidget {
  const _LoadingStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(Color(0xFF14665E)),
            SizedBox(width: 4),
            _Dot(Color(0xFF91B7AA)),
            SizedBox(width: 4),
            _Dot(Color(0xFFD6E4D7)),
          ],
        ),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Roboto', fontSize: 12, color: Color(0xFF647D78), height: 1.4)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
