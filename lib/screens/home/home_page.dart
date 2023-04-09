import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:cognitive_training/screens/gmaes/lottery_game/lottery_game.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var userInfoProvider = context.watch<UserInfoProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('home page'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
              // const SizedBox(
              //   height: 40,
              // ),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blueGrey,
              //   ),
              //   onPressed: () {
              //     userInfoProvider.coins = userInfoProvider.coins + 1;
              //   },
              //   child: const Text(
              //     'press me to update coins',
              //     style: TextStyle(fontSize: 40, color: Colors.white),
              //   ),
              // ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  GoRouter.of(context).push('/home/lottery_game_menu');
                },
                child: const Text(
                  'Lottery game',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  GoRouter.of(context).push('/home/poker_game_menu');
                },
                child: const Text(
                  'Poker game',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  showDialog(
                      context: context, builder: (context) => MyDialog());
                },
                child: const Text(
                  'check in',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
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
                GoRouter.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) {
                  GoRouter.of(context).pop();
                  GoRouter.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class MyDialog extends StatelessWidget {
  const MyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final seperateSize = width * 0.05;
    final iconSize = width * 0.13;
    final fontSize = width * 0.05;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.brown[100],
      child: Container(
        padding: EdgeInsets.all(seperateSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('連 續 登 入',
                style: TextStyle(
                    fontSize: fontSize * 2,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: seperateSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 4; i++) ...[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              size: iconSize,
                              color: Colors.yellow,
                            ),
                            Opacity(
                              opacity: 0.5,
                              child: Icon(Icons.check),
                            ),
                          ],
                        ),
                        Text(
                          '+${i}00',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                  ),
                  if (i != 4) SizedBox(width: seperateSize),
                ],
              ],
            ),
            SizedBox(height: seperateSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 5; i <= 7; i++) ...[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              size: iconSize,
                              color: Colors.yellow,
                            ),
                            Opacity(
                              opacity: 0.5,
                              child: Icon(Icons.check),
                            ),
                          ],
                        ),
                        Text(
                          '+${i}00',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                  ),
                  if (i != 7) SizedBox(width: seperateSize),
                ],
              ],
            ),
            SizedBox(height: seperateSize),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '關閉',
                  style: TextStyle(fontSize: fontSize),
                )),
          ],
        ),
      ),
    );
  }
}
