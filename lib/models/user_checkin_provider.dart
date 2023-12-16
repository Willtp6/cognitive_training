import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/user_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class UserCheckinProvider extends ChangeNotifier {
  User? _user;

  UserCheckinProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != _user) {
        _user = newUser;
        FirebaseFirestore.instance
            .collection('user_checkin_info')
            .doc(newUser?.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            //* shared info
            _currentWeek = doc.data()!['currentWeek'] ?? 0;
            if (doc.data()!['cycleStartDay'] != null) {
              _cycleStartDay = doc.data()!['cycleStartDay'].toDate();
            } else {
              _cycleStartDay = DateTime.now();
            }
            //* for check in reward
            _loginCycle = (doc.data()!['loginCycle'] ?? List.filled(7, false))
                .cast<bool>();
            _loginRewardCycle =
                (doc.data()!['loginRewardCycle'] ?? List.filled(7, false))
                    .cast<bool>();
            //* for bonus reward
            _bonusRewardCycle = (doc.data()!['bonusRewardCycle'] ??
                    List.filled(3, 'unqualification'))
                .cast<String>();
            Logger().d(_bonusRewardCycle);
            _maxPlayTime =
                (doc.data()!['maxPlayTime'] ?? List.filled(7, 0)).cast<int>();
            _accumulatePlayTime =
                (doc.data()!['accumulatePlayTime'] ?? List.filled(7, 0))
                    .cast<int>();
            //* login record
            lastLoginTime = DateTime.now();
            lastUpdateTime = DateTime.now();

            DateTime startDay = DateTime(
                _cycleStartDay.year, _cycleStartDay.month, _cycleStartDay.day);
            DateTime currentTime = DateTime.now();
            int differenceInDays =
                DateTime(currentTime.year, currentTime.month, currentTime.day)
                    .difference(startDay)
                    .inDays;

            //* is difference >= 28 is a new 4 week loop reset startday to now
            if (differenceInDays >= 28) {
              cycleStartDay = DateTime.now();
              differenceInDays = 0;
            }

            Logger().d(differenceInDays);

            //* if difference >= 7 is a new week
            int newWeek = differenceInDays ~/ 7;
            Logger().d(newWeek);
            if (_currentWeek != newWeek) {
              //* reset week data because it is a new week
              loginCycle = List.filled(7, false);
              loginRewardCycle = List.filled(7, false);
              //* reset week data because it is a new week
              bonusRewardCycle = List.filled(3, 'unqualification');
              maxPlayTime = List.filled(7, 0);
              accumulatePlayTime = List.filled(7, 0);
              currentWeek = newWeek;
            }
            isHaveCheckinReward();
            isHaveBonusReward();
          } else {
            //! this part should throw error about data missing
            UserDatabaseService(docId: newUser!.uid).createUserCheckinInfo();
          }
        }).whenComplete(() => notifyListeners());
      }
    });
  }

  //* identify the week index range is from 0 ~ 3
  int _currentWeek = 0;
  int get currentWeek => _currentWeek;
  set currentWeek(int newWeek) {
    _currentWeek = newWeek;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'currentWeek': newWeek, 'lastUpdateTime': DateTime.now()});
  }

  DateTime _lastLoginTime = DateTime.now();
  DateTime get lastLoginTime => _lastLoginTime;
  set lastLoginTime(DateTime dateTime) {
    _lastLoginTime = dateTime;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'lastLoginTime': dateTime, 'lastUpdateTime': DateTime.now()});
  }

  DateTime _lastUpdateTime = DateTime.now();
  DateTime get lastUpdateTime => _lastUpdateTime;
  set lastUpdateTime(DateTime dateTime) {
    _lastUpdateTime = dateTime;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'lastUpdateTime': dateTime});
  }

  DateTime _cycleStartDay = DateTime.now();
  DateTime get cycleStartDay => _cycleStartDay;
  set cycleStartDay(DateTime dateTime) {
    _cycleStartDay = dateTime;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'cycleStartDay': dateTime, 'lastUpdateTime': DateTime.now()});
  }

  List<bool> _loginCycle = List.filled(7, false);
  List<bool> get loginCycle => _loginCycle;
  set loginCycle(List<bool> newList) {
    _loginCycle = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'loginCycle': newList, 'lastUpdateTime': DateTime.now()});
  }

  List<bool> _loginRewardCycle = List.filled(7, false);
  List<bool> get loginRewardCycle => _loginRewardCycle;
  set loginRewardCycle(List<bool> newList) {
    _loginRewardCycle = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update(
            {'loginRewardCycle': newList, 'lastUpdateTime': DateTime.now()});
  }

  bool _haveCheckinReward = false;
  bool get haveCheckinReward => _haveCheckinReward;
  set haveCheckinReward(bool value) {
    _haveCheckinReward = value;
    notifyListeners();
  }

  /// update checkin cycle also indicate that if there is any reward to receive
  void isHaveCheckinReward() {
    DateTime startDay =
        DateTime(_cycleStartDay.year, _cycleStartDay.month, _cycleStartDay.day);
    DateTime currentTime = DateTime.now();
    int differenceInDays =
        DateTime(currentTime.year, currentTime.month, currentTime.day)
            .difference(startDay)
            .inDays;

    //* set the cycle login day to true then check if have reward to get
    _loginCycle[differenceInDays.remainder(7)] = true;
    loginCycle = _loginCycle;
    if (listEquals(loginCycle, loginRewardCycle) == false) {
      haveCheckinReward = true;
    }
    // notifyListeners();
  }

  List<String> _bonusRewardCycle = List.filled(3, 'unqualification');
  List<String> get bonusRewardCycle => _bonusRewardCycle;
  set bonusRewardCycle(List<String> newList) {
    _bonusRewardCycle = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update(
            {'bonusRewardCycle': newList, 'lastUpdateTime': DateTime.now()});
  }

  List<int> _maxPlayTime = List.filled(7, 0);
  List<int> get maxPlayTime => _maxPlayTime;
  set maxPlayTime(List<int> newList) {
    _maxPlayTime = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update({'maxPlayTime': newList, 'lastUpdateTime': DateTime.now()});
  }

  List<int> _accumulatePlayTime = List.filled(7, 0);
  List<int> get accumulatePlayTime => _accumulatePlayTime;
  set accumulatePlayTime(List<int> newList) {
    _accumulatePlayTime = newList;
    FirebaseFirestore.instance
        .collection('user_checkin_info')
        .doc(_user?.uid)
        .update(
            {'accumulatePlayTime': newList, 'lastUpdateTime': DateTime.now()});
  }

  bool _haveBonusReward = false;
  bool get haveBonusReward => _haveBonusReward;
  set haveBonusReward(bool value) {
    _haveBonusReward = value;
    notifyListeners();
  }

  void isHaveBonusReward() {
    bool hasBonusReward = false;
    if (maxPlayTime.any((element) => element >= 30) &&
        _bonusRewardCycle[0] == 'unqualification') {
      _bonusRewardCycle[0] = 'uncollected';
      hasBonusReward = true;
    }

    if (accumulatePlayTime.where((element) => element >= 5).length >= 3 &&
        _bonusRewardCycle[1] == 'unqualification') {
      _bonusRewardCycle[1] = 'uncollected';
      hasBonusReward = true;
    }

    if (maxPlayTime.where((element) => element >= 30).length >= 3 &&
        _bonusRewardCycle[2] == 'unqualification') {
      _bonusRewardCycle[2] = 'uncollected';
      hasBonusReward = true;
    }
    bonusRewardCycle = _bonusRewardCycle;
    if (hasBonusReward) haveBonusReward = true;
  }

  /// if user tapped the reward image it will call this functinon to handle
  /// the change in database and return the reward user will get
  int updateRewardStatus(int index) {
    int reward = 0;
    //* if user have logged in but have not claimed the reward
    if (_loginCycle[index] && !_loginRewardCycle[index]) {
      List<bool> tmp = List.from(_loginRewardCycle);
      tmp[index] = true;
      loginRewardCycle = tmp;
      reward = (index + 1) * 100;
    }
    if (listEquals(_loginCycle, _loginRewardCycle)) {
      haveCheckinReward = false;
      // notifyListeners();
    }
    return reward;
  }
}
