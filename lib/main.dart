import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:cognitive_training/screens/authenticate/register.dart';
import 'package:cognitive_training/screens/authenticate/sign_in.dart';
import 'package:cognitive_training/screens/home/home_page.dart';
import 'package:cognitive_training/screens/login/login_page.dart';
import 'package:cognitive_training/screens/splash/splash_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:cognitive_training/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<LocalUser?>.value(
      value: AuthService().user,
      initialData: null,
      catchError: (_, err) {
        return null;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/home': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}
