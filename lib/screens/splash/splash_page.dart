import 'package:flutter/material.dart';
import 'package:cognitive_training/screens/wrapper.dart';
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
      next: (context) => const Wrapper(),
      until: () => Future.delayed(const Duration(seconds: 3)),
      startAnimation: 'Demo',
    );
  }
}
