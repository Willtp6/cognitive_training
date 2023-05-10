import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserCheckinProvider extends ChangeNotifier {
  User? _user;
  int _test = 0;
  int currentWeek = 0;
  bool _isReady = false;
  DateTime _cycleStartDay = DateTime.now();
  DateTime _lastLoginTime = DateTime.now();
  //late DateTime _lastUpdateTime;
  List<bool> _loginCycle = List.generate(7, (index) => false);
  List<bool> _loginRewardCycle = List.generate(7, (index) => false);
  List<bool> _weeklyRewardCycle = [];
  List<int> _accumulatePlayTime = [];
  bool _haveCheckinReward = false;
  bool _haveAccumulatePlayReward = false;

  bool get haveAccumulatePlayReward => _haveAccumulatePlayReward;
  set haveAccumulatePlayReward(bool value) {
    _haveAccumulatePlayReward = value;
    notifyListeners();
  }

  UserCheckinProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != _user) {
        await updateData(newUser);
        _user = newUser;
        Future.delayed(const Duration(milliseconds: 300), () {
          notifyListeners();
        });
      }
    });
  }

  updateData(User? newUser) {
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(newUser?.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        _cycleStartDay = doc.data()!['cycleStartDay'].toDate();
        _lastLoginTime = doc.data()!['lastLoginTime'].toDate();
        _loginCycle = doc.data()!['loginCycle'].cast<bool>();
        _loginRewardCycle = doc.data()!['loginRewardCycle'].cast<bool>();
        _weeklyRewardCycle = doc.data()!['weeklyRewardCycle'].cast<bool>();
        _accumulatePlayTime = doc.data()!['accumulatePlayTime'].cast<int>();
        _haveCheckinReward = false;
        _isReady = true;
        isHaveCheckinReward();
      } else {
        //! this part should throw error about data missing
        //TODO add some function which will notice the user to developer or someone who can modify the database
      }
    });
  }

  bool get isReady => _isReady;

  int get test => _test;
  set test(int number) {
    _test = number;
    notifyListeners();
  }

  bool get haveCheckinReward => _haveCheckinReward;
  set haveCheckinReward(bool value) {
    _haveCheckinReward = value;
    notifyListeners();
  }

  DateTime get lastLoginTime => _lastLoginTime;
  set lastLoginTime(DateTime dateTime) {
    _lastLoginTime = dateTime;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'lastLoginTime': dateTime}).then((value) {
      notifyListeners();
    });
  }

  // DateTime get lastUpdateTime => _lastUpdateTime;
  // set lastUpdateTime(DateTime dateTime) {
  //   _lastUpdateTime = dateTime;
  //   FirebaseFirestore.instance
  //       .collection('user_checkin_info')
  //       .doc(_user?.uid)
  //       .update({'lastUpdateTime': dateTime}).then((value) {
  //     notifyListeners();
  //   });
  // }

  DateTime get cycleStartDay => _cycleStartDay;
  set cycleStartDay(DateTime dateTime) {
    _cycleStartDay = dateTime;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'cycleStartDay': dateTime}).then((value) {
      notifyListeners();
    });
  }

  List<bool> get loginCycle => _loginCycle;
  set loginCycle(List<bool> newList) {
    _loginCycle = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'loginCycle': newList}).then((value) {
      notifyListeners();
    });
  }

  List<bool> get loginRewardCycle => _loginRewardCycle;
  set loginRewardCycle(List<bool> newList) {
    _loginRewardCycle = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'loginRewardCycle': newList}).then((value) {
      notifyListeners();
    });
  }

  void isHaveCheckinReward() {
    haveCheckinReward = false;
    DateTime startDay =
        DateTime(_cycleStartDay.year, _cycleStartDay.month, _cycleStartDay.day);
    int difference = DateTime.now().difference(startDay).inDays;

    // is difference >= 28 is a new 4 week loop reset startday to now
    if (difference >= 28) cycleStartDay = DateTime.now();
    // if difference >= 7 is a new week
    if (difference >= 7) currentWeek = difference ~/ 7;

    // set the cycle login day to true then check if have reward to get
    _loginCycle[difference.remainder(7)] = true;
    loginCycle = _loginCycle;
    for (int i = 0; i < 7; i++) {
      if (_loginCycle[i] && !loginRewardCycle[i]) {
        haveCheckinReward = true;
      }
    }
    notifyListeners();
  }

  void isHaveAccumulatePlayReward() {
    DateTime startDay =
        DateTime(_cycleStartDay.year, _cycleStartDay.month, _cycleStartDay.day);
    int diff = DateTime.now().difference(startDay).inDays;
    if (_accumulatePlayTime[diff.remainder(7)] > 30) {
      haveAccumulatePlayReward = true;
    }
  }

  int calculateReward() {
    int reward = 0;
    for (int i = 0; i < 7; i++) {
      if (_loginCycle[i] && !_loginRewardCycle[i]) {
        reward += (i + 1) * 100;
      }
    }
    return reward;
  }

  int updateRewardStatus(int index) {
    int reward = 0;
    if (_loginCycle[index] && !_loginRewardCycle[index]) {
      dynamic tmp = _loginRewardCycle;
      tmp[index] = true;
      loginRewardCycle = tmp;
      reward = (index + 1) * 100;
    }
    isHaveCheckinReward();
    return reward;
  }
}
