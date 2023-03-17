import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home page'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async {
              await _authService.signOut();
            },
            label: Text('logout'),
            icon: Icon(Icons.person),
          )
        ],
      ),
      body: const Center(
        child: Text('hello'),
      ),
    );
  }
}
