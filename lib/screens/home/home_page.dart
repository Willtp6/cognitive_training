import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  int numOfCoins = 0;

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<LocalUser?>(context);
    var userInfoProvider = context.watch<UserInfoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('home page'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          Consumer<UserInfoProvider>(
            builder: (context, userInfoProvider, child) {
              return Text(
                "Coins you have: ${userInfoProvider.coins}",
                style: const TextStyle(color: Colors.black, fontSize: 40),
              );
            },
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            onPressed: () {
              //reference.update({'coins': numOfCoins + 1});
              userInfoProvider.coins = userInfoProvider.coins + 1;
            },
            child: const Text(
              'press me to update coins',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            onPressed: () {
              _navigateToLotteryGame(context);
            },
            child: const Text(
              'Lottery game',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
        ],
      )),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Consumer<UserInfoProvider>(
                builder: (context, userInfoProvider, child) {
                  return Text(
                    "Coins you have: ${userInfoProvider.coins}",
                    style: const TextStyle(color: Colors.pink, fontSize: 20),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Logout'),
              onTap: () async {
                _showAlertDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  void _navigateToLotteryGame(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LotteryGame()));
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout ?'),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Once you log out you\'ll need to login again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
