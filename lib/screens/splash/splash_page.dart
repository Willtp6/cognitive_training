import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen.navigate(
      name: 'assets/liquid_download.riv',
      next: (context) => const HomePage(),
      until: () => Future.delayed(const Duration(seconds: 3)),
      startAnimation: 'Demo',
    );
  }
}
