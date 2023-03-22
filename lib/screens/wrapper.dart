import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:cognitive_training/models/user.dart';
import 'package:cognitive_training/screens/home/home_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    Logger().v('called');
    if (user == null) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }
}
