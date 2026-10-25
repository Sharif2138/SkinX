import 'package:flutter/material.dart';
import 'package:skinx/splash_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  runApp(const SkinX());
}

class SkinX extends StatelessWidget {
  const SkinX({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}
