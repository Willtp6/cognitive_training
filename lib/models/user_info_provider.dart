import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserInfoProvider with ChangeNotifier {
  User? _user;
  bool _fileFunctionNormally = false;
  int _coins = 0;
  String _userName = '';
  late DateTime _registerTime;
  late LotteryGameDatabase _lotteryGameDatabase;
  late PokerGameDatabase _pokerGameDatabase;

  UserInfoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != _user) {
        await updateUserData(newUser);
        _user = newUser;
        // delay for the consumer initilaize time
        Future.delayed(const Duration(milliseconds: 200), () {
          notifyListeners();
        });
      }
    });
  }

  Future<void> updateUserData(User? newUser) async {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(newUser?.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        _fileFunctionNormally = true;
        _coins = doc.data()!['coins'];
        _userName = doc.data()!['userName'];
        _registerTime = doc.data()!['registerTime'].toDate();
        _lotteryGameDatabase = LotteryGameDatabase(
          currentLevel: doc.data()!['lotteryGameDatabase']['level'],
          currentDigit: doc.data()!['lotteryGameDatabase']['digit'],
          doneTutorial: doc.data()!['lotteryGameDatabase']['doneTutorial'],
        );
        List<dynamic> responseTimeList = doc.data()!['pokerGameDatabase']
                ['responseTimeList'] ??
            [10000, 10000, 10000, 10000, 10000];
        _pokerGameDatabase = PokerGameDatabase(
          currentLevel: doc.data()!['pokerGameDatabase']['level'],
          doneTutorial: doc.data()!['pokerGameDatabase']['doneTutorial'],
          responseTimeList: responseTimeList.cast<int>(),
        );
      } else {
        //! this part should throw error about data missing
        //TODO add some function which will notice the user to developer or someone who can modify the database
        _fileFunctionNormally = false;
      }
    });
  }

  User? get usr => _user;
  bool get fileFunctionNormally => _fileFunctionNormally;
  DateTime get registerTime => _registerTime;
  String get userName => _userName;

  int get coins => _coins;
  set coins(int value) {
    _coins = value;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({'coins': _coins}).then((value) {
      notifyListeners();
    });
  }

  LotteryGameDatabase get lotteryGameDatabase => _lotteryGameDatabase;
  set lotteryGameDatabase(LotteryGameDatabase database) {
    _lotteryGameDatabase = database;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'lotteryGameDatabase': {
        'level': database.currentLevel,
        'digit': database.currentDigit,
        'doneTutorial': database.doneTutorial,
      }
    }).then((value) {
      Logger().d('complete');
      notifyListeners();
    });
  }

  void lotteryGameDoneTutorial() {
    _pokerGameDatabase.doneTutorial = true;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'lotteryGameDatabase': {
        'level': _lotteryGameDatabase.currentLevel,
        'digit': _lotteryGameDatabase.currentDigit,
        'doneTutorial': true,
      }
    }).then((value) {
      notifyListeners();
    });
  }

  PokerGameDatabase get pokerGameDatabase => _pokerGameDatabase;
  set pokerGameDatabase(PokerGameDatabase database) {
    // _pokerGameDatabase = PokerGameDatabase(
    //   currentLevel: database.currentLevel,
    //   doneTutorial: database.doneTutorial,
    //   responseTimeList: database.responseTimeList,
    // );
    _pokerGameDatabase = database;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'pokerGameDatabase': {
        'level': database.currentLevel,
        'doneTutorial': database.doneTutorial,
        'responseTimeList': database.responseTimeList,
      }
    }).then((value) {
      notifyListeners();
    });
  }

  void pokerGameDoneTutorial() {
    _pokerGameDatabase.doneTutorial = true;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'pokerGameDatabase': {
        'level': _lotteryGameDatabase.currentLevel,
        'digit': _lotteryGameDatabase.currentDigit,
        'doneTutorial': true,
      }
    }).then((value) {
      notifyListeners();
    });
  }
}
