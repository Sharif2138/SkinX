import 'package:flutter/material.dart';
import 'package:skinx/splash_screen.dart';

void main() {
  runApp(const SkinX());
}

class SkinX extends StatelessWidget {
  const SkinX({super.key});

  // This widget is the root of your application.
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
