import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/user_database_service.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserInfoProvider with ChangeNotifier {
  User? _user;
  int _coins = 0;
  String _userName = '';
  late LotteryGameDatabase _lotteryGameDatabase;
  late FishingGameDatabase _fishingGameDatabase;
  late PokerGameDatabase _pokerGameDatabase;
  late RoutePlanningGameDatabase _routePlanningGameDatabase;

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
        _coins = doc.data()!['coins'] ?? 1200;
        _userName = doc.data()!['userName'] ?? newUser!.displayName;
        //* part of lottery game
        if (doc.data()!['lotteryGameDatabase'] != null) {
          _lotteryGameDatabase = LotteryGameDatabase(
            currentLevel: doc.data()!['lotteryGameDatabase']['level'] ?? 0,
            currentDigit: doc.data()!['lotteryGameDatabase']['digit'] ?? 2,
            historyContinuousWin:
                doc.data()!['lotteryGameDatabase']['historyContinuousWin'] ?? 0,
            historyContinuousLose: doc.data()!['lotteryGameDatabase']
                    ['historyContinuousLose'] ??
                0,
            doneTutorial:
                doc.data()!['lotteryGameDatabase']['doneTutorial'] ?? false,
          );
        } else {
          _lotteryGameDatabase = LotteryGameDatabase(
            currentLevel: 0,
            currentDigit: 2,
            historyContinuousWin: 0,
            historyContinuousLose: 0,
            doneTutorial: false,
          );
        }
        //* part of fishing game
        if (doc.data()!['fishingGameDatabase'] != null) {
          _fishingGameDatabase = FishingGameDatabase(
            currentLevel: doc.data()!['fishingGameDatabase']['level'] ?? 0,
            historyContinuousWin:
                doc.data()!['fishingGameDatabase']['historyContinuousWin'] ?? 0,
            historyContinuousLose: doc.data()!['fishingGameDatabase']
                    ['historyContinuousLose'] ??
                0,
            doneTutorial:
                doc.data()!['fishingGameDatabase']['doneTutorial'] ?? false,
          );
        } else {
          _fishingGameDatabase = FishingGameDatabase(
            currentLevel: 0,
            historyContinuousWin: 0,
            historyContinuousLose: 0,
            doneTutorial: false,
          );
        }

        //* part of poker game
        if (doc.data()!['pokerGameDatabase'] != null) {
          _pokerGameDatabase = PokerGameDatabase(
            currentLevel: doc.data()!['pokerGameDatabase']['level'] ?? 0,
            historyContinuousWin:
                doc.data()!['pokerGameDatabase']['historyContinuousWin'] ?? 0,
            historyContinuousLose:
                doc.data()!['pokerGameDatabase']['historyContinuousLose'] ?? 0,
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
            historyContinuousWin: 0,
            historyContinuousLose: 0,
            doneTutorial: false,
            responseTimeList: [10000, 10000, 10000, 10000, 10000],
          );
        }

        if (doc.data()!['routePlanningGameDatabase'] != null) {
          _routePlanningGameDatabase = RoutePlanningGameDatabase(
            currentLevel:
                doc.data()!['routePlanningGameDatabase']['level'] ?? 0,
            historyContinuousWin: doc.data()!['routePlanningGameDatabase']
                    ['historyContinuousWin'] ??
                0,
            historyContinuousLose: doc.data()!['routePlanningGameDatabase']
                    ['historyContinuousLose'] ??
                0,
            doneTutorial: doc.data()!['routePlanningGameDatabase']
                ['doneTutorial'],
            responseTimeList: (doc.data()!['routePlanningGameDatabase']
                        ['responseTimeList'] ??
                    List.generate(5, (_) => 30000))
                .cast<int>(),
          );
        } else {
          _routePlanningGameDatabase = RoutePlanningGameDatabase(
            currentLevel: 0,
            historyContinuousWin: 0,
            historyContinuousLose: 0,
            doneTutorial: false,
            responseTimeList: [],
          );
        }
      } else {
        //! this part should throw error about data missing
        //TODO add some function which will notice the user to developer or someone who can modify the database

        //* maybe just create a new one
        // create new user info database
        UserDatabaseService(
          docId: newUser!.uid,
          userName: userName,
        ).createUserBasicInfo();
      }
    });
  }

  User? get usr => _user;
  String get userName => _userName;

  int get coins => _coins;
  set coins(int value) {
    _coins = value;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({'coins': _coins}).whenComplete(() {
      notifyListeners();
    });
    FirebaseFirestore.instance.collection('global_info').doc(_user?.uid).set({
      'coins': _coins,
      'user_name': _userName,
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
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
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
        'historyContinuousWin': _lotteryGameDatabase.historyContinuousWin,
        'historyContinuousLose': _lotteryGameDatabase.historyContinuousLose,
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
            'historyContinuousWin': database.historyContinuousWin,
            'historyContinuousLose': database.historyContinuousLose,
            'doneTutorial': database.doneTutorial,
          }
        })
        .onError((error, stackTrace) => Logger().d(error))
        .then((value) {
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
      'fishingGameDatabase': {
        'level': _fishingGameDatabase.currentLevel,
        'historyContinuousWin': _fishingGameDatabase.historyContinuousWin,
        'historyContinuousLose': _fishingGameDatabase.historyContinuousLose,
        'doneTutorial': true,
      }
    }).then((value) {
      Logger().d('complete');
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
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
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
        'level': _pokerGameDatabase.currentLevel,
        'historyContinuousWin': _pokerGameDatabase.historyContinuousWin,
        'historyContinuousLose': _pokerGameDatabase.historyContinuousLose,
        'doneTutorial': true,
        'responseTimeList': _pokerGameDatabase.responseTimeList,
      }
    }).then((value) {
      notifyListeners();
    });
  }

  RoutePlanningGameDatabase get routePlanningGameDatabase =>
      _routePlanningGameDatabase;
  set routePlanningGameDatabase(RoutePlanningGameDatabase database) {
    _routePlanningGameDatabase = database;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'routePlanningGameDatabase': {
        'level': database.currentLevel,
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
        'doneTutorial': database.doneTutorial,
        'responseTimeList': database.responseTimeList,
      },
    });
  }

  void routePlanningGameDoneTutorial() {
    _routePlanningGameDatabase.doneTutorial = true;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(_user?.uid)
        .update({
      'routePlanningGameDatabase': {
        'level': _routePlanningGameDatabase.currentLevel,
        'historyContinuousWin': _routePlanningGameDatabase.historyContinuousWin,
        'historyContinuousLose':
            _routePlanningGameDatabase.historyContinuousLose,
        'doneTutorial': true,
        'responseTimeList': _routePlanningGameDatabase.responseTimeList,
      },
    });
  }
}
