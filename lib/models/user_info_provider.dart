import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LotteryGameDatabase {
  int currentLevel;
  int currentDigit;
  bool doneTutorial;
  LotteryGameDatabase(
      {required this.currentLevel,
      required this.currentDigit,
      required this.doneTutorial});
}

class PokerGameDatabase {
  int currentLevel;
  bool doneTutorial;
  PokerGameDatabase({required this.currentLevel, required this.doneTutorial});
}

class UserInfoProvider with ChangeNotifier {
  //var user = FirebaseAuth.instance.currentUser;
  User? _user;
  int _coins = 0;
  late LotteryGameDatabase _lotteryGameDatabase;
  late PokerGameDatabase _pokerGameDatabase;

  UserInfoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      if (newUser != null && newUser != _user) {
        updateUser(newUser);
      }
    });
  }

  User? get usr => _user;
  int get coins => _coins;
  LotteryGameDatabase get lotteryGameDatabase => _lotteryGameDatabase;
  PokerGameDatabase get pokerGameDatabase => _pokerGameDatabase;

  void updateUser(User newUser) {
    _user = newUser;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user!.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        _coins = doc.data()!['coins'];
        _lotteryGameDatabase = LotteryGameDatabase(
          currentLevel: doc.data()!['lotteryGameDatabase']['level'],
          currentDigit: doc.data()!['lotteryGameDatabase']['digits'],
          doneTutorial: doc.data()!['lotteryGameDatabase']['doneTutorial'],
        );
        _pokerGameDatabase = PokerGameDatabase(
          currentLevel: doc.data()!['pokerGameDatabase']['level'],
          doneTutorial: doc.data()!['pokerGameDatabase']['doneTutorial'],
        );
      } else {
        _coins = 0;
        _lotteryGameDatabase = LotteryGameDatabase(
            currentLevel: 0, currentDigit: 2, doneTutorial: false);
        _pokerGameDatabase =
            PokerGameDatabase(currentLevel: 0, doneTutorial: false);
      }
      notifyListeners();
    });
  }

  set coins(int value) {
    _coins = value;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({'coins': _coins}).then((value) {
      notifyListeners();
    });
  }

  set lotteryGameDatabase(LotteryGameDatabase database) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'lotteryGameDatabase': {
        'level': database.currentLevel,
        'digits': database.currentDigit,
        'doneTutorial': database.doneTutorial,
      }
    }).then((value) {
      notifyListeners();
      Logger().d('updated map');
    });
  }

  set pokerGameDatabase(PokerGameDatabase database) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(usr?.uid)
        .update({
      'pokerGameDatabase': {
        'level': database.currentLevel,
        'doneTutorial': database.doneTutorial,
      }
    });
  }
}
