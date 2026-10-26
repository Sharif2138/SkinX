import '../services/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OfflineWelcome extends StatelessWidget {
  const OfflineWelcome({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/skinx_logo.svg', width: 64, height: 64),
                  const SizedBox(height: 22),
                  const SkinXText('SkinX offline mode', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Color(0xFF193B38), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const SkinXText('Internet is not available. You can still screen a skin photo, ask skin-health questions, learn and see saved results on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF647D78))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF14665E),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const SkinXText('Continue offline without an account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SkinXText('Sign-in and cloud services become available when connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF647D78))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
