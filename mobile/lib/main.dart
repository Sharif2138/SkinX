import 'package:flutter/material.dart';
import 'package:skinx/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/app_language.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  await AppLanguage.instance.initialize();
  runApp(const SkinX());
}

class SkinX extends StatelessWidget {
  const SkinX({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) => MaterialApp(
      title: 'SkinX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    ),
    );
  }
}
