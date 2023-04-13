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
  User? _user;
  bool _fileFunctionNormally = false;
  late int _coins;
  late DateTime _registerTime;
  late DateTime _lastLoginTime;
  late DateTime _lastUpdateTime;
  late int _continuousLoginDays;
  late List<bool> _loginCycle;
  late List<bool> _loginRewardRecord;
  late LotteryGameDatabase _lotteryGameDatabase;
  late PokerGameDatabase _pokerGameDatabase;

  UserInfoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      await updateUserData(newUser);
      _user = newUser;
      notifyListeners();
    });
  }

  User? get usr => _user;
  bool get fileFunctionNormally => _fileFunctionNormally;
  int get coins => _coins;
  DateTime get registerTime => _registerTime;
  DateTime get lastLoginTime => _lastLoginTime;
  DateTime get lastUpdateTime => _lastUpdateTime;
  int get continuousLoginDays => _continuousLoginDays;
  List<bool> get loginCycle => _loginCycle;
  List<bool> get loginRewardRecord => _loginRewardRecord;
  LotteryGameDatabase get lotteryGameDatabase => _lotteryGameDatabase;
  PokerGameDatabase get pokerGameDatabase => _pokerGameDatabase;

  Future updateUserData(User? newUser) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(newUser?.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        Logger().d(newUser?.uid);
        _fileFunctionNormally = true;
        _coins = doc.data()!['coins'];
        Timestamp timestampRegister = doc.data()!['registerTime'];
        _registerTime = timestampRegister.toDate();
        Timestamp timestampLogin = doc.data()!['lastLoginTime'];
        _lastLoginTime = timestampLogin.toDate();
        Timestamp timestampUpdate = doc.data()!['lastUpdateTime'];
        _lastUpdateTime = timestampUpdate.toDate();
        _continuousLoginDays = doc.data()!['continuousLoginDays'];
        _loginCycle = doc.data()!['loginCycle'].cast<bool>();
        _loginRewardRecord = doc.data()!['loginRewardRecord'].cast<bool>();
        _lotteryGameDatabase = LotteryGameDatabase(
          currentLevel: doc.data()!['lotteryGameDatabase']['level'],
          currentDigit: doc.data()!['lotteryGameDatabase']['digit'],
          doneTutorial: doc.data()!['lotteryGameDatabase']['doneTutorial'],
        );
        _pokerGameDatabase = PokerGameDatabase(
          currentLevel: doc.data()!['pokerGameDatabase']['level'],
          doneTutorial: doc.data()!['pokerGameDatabase']['doneTutorial'],
        );
        Logger().d('success');
      } else {
        //! this part should throw error about data missing
        //TODO add some function which will notice the user to developer or someone who can modify the database
        _fileFunctionNormally = false;
        Logger().d('error');
      }
    });
    // delay for the conaumer initilaize time
    Future.delayed(Duration(milliseconds: 100), () {
      notifyListeners();
    });
    return Future.value(true);
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
    _lotteryGameDatabase = LotteryGameDatabase(
        currentLevel: database.currentLevel,
        currentDigit: database.currentDigit,
        doneTutorial: database.doneTutorial);
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
      notifyListeners();
      Logger().d('updated map');
    });
  }

  set pokerGameDatabase(PokerGameDatabase database) {
    _pokerGameDatabase = PokerGameDatabase(
        currentLevel: database.currentLevel,
        doneTutorial: database.doneTutorial);
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(usr?.uid)
        .update({
      'pokerGameDatabase': {
        'level': database.currentLevel,
        'doneTutorial': database.doneTutorial,
      }
    }).then((value) {
      notifyListeners();
    });
  }

  set lastLoginTime(DateTime dateTime) {
    _lastLoginTime = dateTime;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(usr?.uid)
        .update({'lastLoginTime': dateTime}).then((value) {
      notifyListeners();
    });
  }

  set lastUpdateTime(DateTime dateTime) {
    _lastUpdateTime = dateTime;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(usr?.uid)
        .update({'lastUpdateTime': dateTime}).then((value) {
      notifyListeners();
    });
  }
}
