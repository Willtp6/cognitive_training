import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/user_database_service.dart';
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
  late FishingGameDatabase _fishingGameDatabase;
  late PokerGameDatabase _pokerGameDatabase;

  UserInfoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != _user && newUser != null) {
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
        _coins = doc.data()!['coins'] ?? 1200;
        _userName = doc.data()!['userName'] ?? newUser!.displayName;
        _registerTime =
            (doc.data()!['registerTime'] ?? Timestamp.fromDate(DateTime.now()))
                .toDate();
        //* part of lottery game
        if (doc.data()!['lotteryGameDatabase'] != null) {
          _lotteryGameDatabase = LotteryGameDatabase(
            currentLevel: doc.data()!['lotteryGameDatabase']['level'] ?? 0,
            currentDigit: doc.data()!['lotteryGameDatabase']['digit'] ?? 2,
            doneTutorial:
                doc.data()!['lotteryGameDatabase']['doneTutorial'] ?? false,
          );
        } else {
          _lotteryGameDatabase = LotteryGameDatabase(
            currentLevel: 0,
            currentDigit: 2,
            doneTutorial: false,
          );
        }
        //* part of fishing game
        if (doc.data()!['fishingGameDatabase'] != null) {
          _fishingGameDatabase = FishingGameDatabase(
            currentLevel: doc.data()!['fishingGameDatabase']['level'] ?? 0,
            doneTutorial:
                doc.data()!['fishingGameDatabase']['doneTutorial'] ?? false,
          );
        } else {
          _fishingGameDatabase = FishingGameDatabase(
            currentLevel: 0,
            doneTutorial: false,
          );
        }

        //* part of poker game
        if (doc.data()!['pokerGameDatabase'] != null) {
          _pokerGameDatabase = PokerGameDatabase(
            currentLevel: doc.data()!['pokerGameDatabase']['level'] ?? 0,
            doneTutorial:
                doc.data()!['pokerGameDatabase']['doneTutorial'] ?? false,
            responseTimeList: (doc.data()!['pokerGameDatabase']
                        ['responseTimeList'] ??
                    [10000, 10000, 10000, 10000, 10000])
                .cast<int>(),
          );
        } else {
          _pokerGameDatabase = PokerGameDatabase(
            currentLevel: 0,
            doneTutorial: false,
            responseTimeList: [10000, 10000, 10000, 10000, 10000],
          );
        }
      } else {
        //! this part should throw error about data missing
        //TODO add some function which will notice the user to developer or someone who can modify the database
        _fileFunctionNormally = false;

        //* maybe just create a new one
        // create new user info database
        UserDatabaseService(docId: newUser!.uid, userName: userName)
            .createUserBasicInfo();
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
    _lotteryGameDatabase.doneTutorial = true;
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

  FishingGameDatabase get fishingGameDatabase => _fishingGameDatabase;
  set fishingGameDatabase(FishingGameDatabase database) {
    _fishingGameDatabase = database;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'fishingGameDatabase': {
        'level': database.currentLevel,
        'doneTutorial': database.doneTutorial,
      }
    }).then((value) {
      Logger().d('complete');
      notifyListeners();
    });
  }

  void fishingGameDoneTutorial() {
    _fishingGameDatabase.doneTutorial = true;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'lotteryGameDatabase': {
        'level': _fishingGameDatabase.currentLevel,
        'doneTutorial': true,
      }
    }).then((value) {
      notifyListeners();
    });
  }

  PokerGameDatabase get pokerGameDatabase => _pokerGameDatabase;
  set pokerGameDatabase(PokerGameDatabase database) {
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
