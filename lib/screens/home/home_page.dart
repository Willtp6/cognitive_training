import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/get_user_info.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  int num = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    DocumentReference reference =
        FirebaseFirestore.instance.collection('user_basic_info').doc(user!.uid);
    reference.snapshots().listen((querySnapshot) {
      setState(() {
        num = querySnapshot.get('coins');
      });
    });

    final Size size = MediaQuery.of(context).size;

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
      body: Container(
        width: size.width,
        height: size.height,
        child: Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Text(num.toString(),
                style: TextStyle(
                  fontSize: 40,
                )),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              onPressed: () {
                reference.update({'coins': num + 1});
              },
              child: Text(
                'press me to update coins',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              onPressed: () {
                _navigateToLotteryGame(context);
              },
              child: Text(
                'Lottery game',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ],
        )),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text('Drawer Header'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "Coins you have: ${num.toString()}",
                style: TextStyle(color: Colors.pink, fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.abc),
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLotteryGame(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LotteryGame()));
  }
}
