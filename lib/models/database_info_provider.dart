import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitive_training/firebase/user_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_models.dart';

class DatabaseInfoProvider extends ChangeNotifier {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  User? _user;
  User? get usr => _user;

  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('user_basic_info');
  final CollectionReference userCheckinCollection =
      FirebaseFirestore.instance.collection('user_checkin_info');

  DatabaseInfoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != _user && newUser != null) {
        _user = newUser;
        await updateUserData(newUser).whenComplete(() => notifyListeners());
      }
    });
  }

  /// update all data if user update
  /// create new data if data not exists
  Future<void> updateUserData(User? newUser) async {
    //* update basic info
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(newUser?.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        _coins = doc.data()!['coins'] ?? 1200;
        _userName = doc.data()!['userName'] ?? newUser!.displayName;

        //* flush the data because there may have different users
        _openNotifications = doc.data()!['openNotifications'] ?? false;
        setNotoficationStatus(_openNotifications);
        _chosenTime1 = doc.data()!['chosenTime1'] ?? '';
        setNewTime('timeOfDailyNotification1', _chosenTime1);
        _chosenTime2 = doc.data()!['chosenTime2'] ?? '';
        setNewTime('timeOfDailyNotification2', _chosenTime2);
        _chosenTime3 = doc.data()!['chosenTime3'] ?? '';
        setNewTime('timeOfDailyNotification3', _chosenTime3);

        //* part of lottery game
        checkLotteryGameDatabaseStatus(doc);
        //* part of fishing game
        checkFishingGameDatabaseStatus(doc);
        //* part of poker game
        checkPokerGameDatabaseStatus(doc);
        //* part of route planning game
        checkRoutePlanningGameDatabaseStatus(doc);
      } else {
        //* maybe just create a new one
        UserDatabaseService(
          docId: newUser!.uid,
          userName: userName,
        ).createUserBasicInfo();
      }
    });
    //* update reward info
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
        _loginCycle =
            (doc.data()!['loginCycle'] ?? List.filled(7, false)).cast<bool>();
        _loginRewardCycle =
            (doc.data()!['loginRewardCycle'] ?? List.filled(7, false))
                .cast<bool>();
        //* for bonus reward
        _bonusRewardCycle = (doc.data()!['bonusRewardCycle'] ??
                List.filled(3, 'unqualification'))
            .cast<String>();
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

        //* if difference >= 7 is a new week
        int newWeek = differenceInDays ~/ 7;
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
    });
    //* update ranking
    updateRanking();
  }

  /// update lottery game data
  /// create dafault data if can't find
  void checkLotteryGameDatabaseStatus(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data()!['lotteryGameDatabase'] != null) {
      _lotteryGameDatabase = LotteryGameDatabase(
        currentLevel: doc.data()!['lotteryGameDatabase']['level'] ?? 0,
        currentDigit: doc.data()!['lotteryGameDatabase']['digit'] ?? 2,
        continuousCorrectRateBiggerThan50: doc.data()!['lotteryGameDatabase']
                ['continuousCorrectRateBiggerThan50'] ??
            0,
        loseInCurrentDigit:
            doc.data()!['lotteryGameDatabase']['loseInCurrentDigit'] ?? 0,
        historyContinuousWin:
            doc.data()!['lotteryGameDatabase']['historyContinuousWin'] ?? 0,
        historyContinuousLose:
            doc.data()!['lotteryGameDatabase']['historyContinuousLose'] ?? 0,
        doneTutorial:
            doc.data()!['lotteryGameDatabase']['doneTutorial'] ?? false,
      );
    } else {
      _lotteryGameDatabase = LotteryGameDatabase(
        currentLevel: 0,
        currentDigit: 2,
        continuousCorrectRateBiggerThan50: 0,
        loseInCurrentDigit: 0,
        historyContinuousWin: 0,
        historyContinuousLose: 0,
        doneTutorial: false,
      );
    }
  }

  /// update fishing game data
  /// create dafault data if can't find
  void checkFishingGameDatabaseStatus(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data()!['fishingGameDatabase'] != null) {
      _fishingGameDatabase = FishingGameDatabase(
        currentLevel: doc.data()!['fishingGameDatabase']['level'] ?? 0,
        historyContinuousWin:
            doc.data()!['fishingGameDatabase']['historyContinuousWin'] ?? 0,
        historyContinuousLose:
            doc.data()!['fishingGameDatabase']['historyContinuousLose'] ?? 0,
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
  }

  /// update poker game data
  /// create dafault data if can't find
  void checkPokerGameDatabaseStatus(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data()!['pokerGameDatabase'] != null) {
      _pokerGameDatabase = PokerGameDatabase(
        currentLevel: doc.data()!['pokerGameDatabase']['level'] ?? 0,
        historyContinuousWin:
            doc.data()!['pokerGameDatabase']['historyContinuousWin'] ?? 0,
        historyContinuousLose:
            doc.data()!['pokerGameDatabase']['historyContinuousLose'] ?? 0,
        doneTutorial: doc.data()!['pokerGameDatabase']['doneTutorial'] ?? false,
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
  }

  /// update route planning game data
  /// create dafault data if can't find
  void checkRoutePlanningGameDatabaseStatus(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data()!['routePlanningGameDatabase'] != null) {
      _routePlanningGameDatabase = RoutePlanningGameDatabase(
        currentLevel: doc.data()!['routePlanningGameDatabase']['level'] ?? 0,
        historyContinuousWin: doc.data()!['routePlanningGameDatabase']
                ['historyContinuousWin'] ??
            0,
        historyContinuousLose: doc.data()!['routePlanningGameDatabase']
                ['historyContinuousLose'] ??
            0,
        doneTutorial: doc.data()!['routePlanningGameDatabase']['doneTutorial'],
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
  }

  /// udpate local shared preference data
  void setNewTime(String timeName, String newTime) async {
    var pref = await instanceFuture;
    pref.setString(timeName, newTime);
  }

  /// update local shared preference data
  void setNotoficationStatus(newValue) async {
    var pref = await instanceFuture;
    pref.setBool('statusOfDailyNotification', newValue);
  }

  String _userName = '';
  String get userName => _userName;

  int _coins = 0;
  int get coins => _coins;
  set coins(int value) {
    _coins = value;
    userInfoCollection.doc(_user?.uid).update({
      'coins': _coins,
    }).whenComplete(() => notifyListeners());
    //* update the ranking info
    FirebaseFirestore.instance.collection('global_info').doc(_user?.uid).set({
      'coins': _coins,
      'user_name': _userName,
    }).whenComplete(() => notifyListeners());
  }

  bool _openNotifications = true;
  bool get openNotifications => _openNotifications;
  set openNotifications(bool value) {
    _openNotifications = value;
    setNotoficationStatus(value);
    userInfoCollection.doc(_user?.uid).update({
      'openNotifications': value,
    }).whenComplete(() => notifyListeners());
  }

  String _chosenTime1 = '';
  String get chosenTime1 => _chosenTime1;
  set chosenTime1(String newTime) {
    _chosenTime1 = newTime;
    setNewTime('timeOfDailyNotification1', newTime);
    userInfoCollection.doc(_user?.uid).update({
      'chosenTime1': newTime,
    }).whenComplete(() => notifyListeners());
  }

  String _chosenTime2 = '';
  String get chosenTime2 => _chosenTime2;
  set chosenTime2(String newTime) {
    _chosenTime2 = newTime;
    setNewTime('timeOfDailyNotification2', newTime);
    userInfoCollection.doc(_user?.uid).update({
      'chosenTime2': newTime,
    }).whenComplete(() => notifyListeners());
  }

  String _chosenTime3 = '';
  String get chosenTime3 => _chosenTime3;
  set chosenTime3(String newTime) {
    _chosenTime3 = newTime;
    setNewTime('timeOfDailyNotification3', newTime);
    userInfoCollection.doc(_user?.uid).update({
      'chosenTime3': newTime,
    }).whenComplete(() => notifyListeners());
  }

  late LotteryGameDatabase _lotteryGameDatabase;
  LotteryGameDatabase get lotteryGameDatabase => _lotteryGameDatabase;
  set lotteryGameDatabase(LotteryGameDatabase database) {
    _lotteryGameDatabase = database;
    userInfoCollection.doc(_user?.uid).update({
      'lotteryGameDatabase': {
        'level': database.currentLevel,
        'digit': database.currentDigit,
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
        'doneTutorial': database.doneTutorial,
      }
    }).whenComplete(() => notifyListeners());
  }

  void lotteryGameDoneTutorial() {
    _lotteryGameDatabase.doneTutorial = true;
    userInfoCollection.doc(_user?.uid).update({
      'lotteryGameDatabase': {
        'level': _lotteryGameDatabase.currentLevel,
        'digit': _lotteryGameDatabase.currentDigit,
        'historyContinuousWin': _lotteryGameDatabase.historyContinuousWin,
        'historyContinuousLose': _lotteryGameDatabase.historyContinuousLose,
        'doneTutorial': true,
      }
    }).whenComplete(() => notifyListeners());
  }

  late FishingGameDatabase _fishingGameDatabase;
  FishingGameDatabase get fishingGameDatabase => _fishingGameDatabase;
  set fishingGameDatabase(FishingGameDatabase database) {
    _fishingGameDatabase = database;
    userInfoCollection.doc(_user?.uid).update({
      'fishingGameDatabase': {
        'level': database.currentLevel,
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
        'doneTutorial': database.doneTutorial,
      }
    }).whenComplete(() => notifyListeners());
  }

  void fishingGameDoneTutorial() {
    _fishingGameDatabase.doneTutorial = true;
    userInfoCollection.doc(_user?.uid).update({
      'fishingGameDatabase': {
        'level': _fishingGameDatabase.currentLevel,
        'historyContinuousWin': _fishingGameDatabase.historyContinuousWin,
        'historyContinuousLose': _fishingGameDatabase.historyContinuousLose,
        'doneTutorial': true,
      }
    }).whenComplete(() => notifyListeners());
  }

  late PokerGameDatabase _pokerGameDatabase;
  PokerGameDatabase get pokerGameDatabase => _pokerGameDatabase;
  set pokerGameDatabase(PokerGameDatabase database) {
    _pokerGameDatabase = database;
    userInfoCollection.doc(_user?.uid).update({
      'pokerGameDatabase': {
        'level': database.currentLevel,
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
        'doneTutorial': database.doneTutorial,
        'responseTimeList': database.responseTimeList,
      }
    }).whenComplete(() => notifyListeners());
  }

  void pokerGameDoneTutorial() {
    _pokerGameDatabase.doneTutorial = true;
    userInfoCollection.doc(_user?.uid).update({
      'pokerGameDatabase': {
        'level': _pokerGameDatabase.currentLevel,
        'historyContinuousWin': _pokerGameDatabase.historyContinuousWin,
        'historyContinuousLose': _pokerGameDatabase.historyContinuousLose,
        'doneTutorial': true,
        'responseTimeList': _pokerGameDatabase.responseTimeList,
      }
    }).whenComplete(() => notifyListeners());
  }

  late RoutePlanningGameDatabase _routePlanningGameDatabase;
  RoutePlanningGameDatabase get routePlanningGameDatabase =>
      _routePlanningGameDatabase;
  set routePlanningGameDatabase(RoutePlanningGameDatabase database) {
    _routePlanningGameDatabase = database;
    userInfoCollection.doc(_user?.uid).update({
      'routePlanningGameDatabase': {
        'level': database.currentLevel,
        'historyContinuousWin': database.historyContinuousWin,
        'historyContinuousLose': database.historyContinuousLose,
        'doneTutorial': database.doneTutorial,
        'responseTimeList': database.responseTimeList,
      },
    }).whenComplete(() => notifyListeners());
  }

  void routePlanningGameDoneTutorial() {
    _routePlanningGameDatabase.doneTutorial = true;
    userInfoCollection.doc(_user?.uid).update({
      'routePlanningGameDatabase': {
        'level': _routePlanningGameDatabase.currentLevel,
        'historyContinuousWin': _routePlanningGameDatabase.historyContinuousWin,
        'historyContinuousLose':
            _routePlanningGameDatabase.historyContinuousLose,
        'doneTutorial': true,
        'responseTimeList': _routePlanningGameDatabase.responseTimeList,
      },
    }).whenComplete(() => notifyListeners());
  }

  // ----------------------------------------------------------------

  //* identify the week index range is from 0 ~ 3
  int _currentWeek = 0;
  int get currentWeek => _currentWeek;
  set currentWeek(int newWeek) {
    _currentWeek = newWeek;
    userCheckinCollection.doc(_user?.uid).update({
      'currentWeek': newWeek,
      'lastUpdateTime': DateTime.now(),
    });
  }

  DateTime _lastLoginTime = DateTime.now();
  DateTime get lastLoginTime => _lastLoginTime;
  set lastLoginTime(DateTime dateTime) {
    _lastLoginTime = dateTime;
    userCheckinCollection.doc(_user?.uid).update({
      'lastLoginTime': dateTime,
      'lastUpdateTime': DateTime.now(),
    });
  }

  DateTime _lastUpdateTime = DateTime.now();
  DateTime get lastUpdateTime => _lastUpdateTime;
  set lastUpdateTime(DateTime dateTime) {
    _lastUpdateTime = dateTime;
    userCheckinCollection.doc(_user?.uid).update({
      'lastUpdateTime': dateTime,
    });
  }

  DateTime _cycleStartDay = DateTime.now();
  DateTime get cycleStartDay => _cycleStartDay;
  set cycleStartDay(DateTime dateTime) {
    _cycleStartDay = dateTime;
    userCheckinCollection.doc(_user?.uid).update({
      'cycleStartDay': dateTime,
      'lastUpdateTime': DateTime.now(),
    });
  }

  List<bool> _loginCycle = List.filled(7, false);
  List<bool> get loginCycle => _loginCycle;
  set loginCycle(List<bool> newList) {
    _loginCycle = newList;
    userCheckinCollection.doc(_user?.uid).update({
      'loginCycle': newList,
      'lastUpdateTime': DateTime.now(),
    });
  }

  List<bool> _loginRewardCycle = List.filled(7, false);
  List<bool> get loginRewardCycle => _loginRewardCycle;
  set loginRewardCycle(List<bool> newList) {
    _loginRewardCycle = newList;
    userCheckinCollection.doc(_user?.uid).update({
      'loginRewardCycle': newList,
      'lastUpdateTime': DateTime.now(),
    });
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
  }

  List<String> _bonusRewardCycle = List.filled(3, 'unqualification');
  List<String> get bonusRewardCycle => _bonusRewardCycle;
  set bonusRewardCycle(List<String> newList) {
    _bonusRewardCycle = newList;
    userCheckinCollection.doc(_user?.uid).update({
      'bonusRewardCycle': newList,
      'lastUpdateTime': DateTime.now(),
    });
  }

  List<int> _maxPlayTime = List.filled(7, 0);
  List<int> get maxPlayTime => _maxPlayTime;
  set maxPlayTime(List<int> newList) {
    _maxPlayTime = newList;
    userCheckinCollection.doc(_user?.uid).update({
      'maxPlayTime': newList,
      'lastUpdateTime': DateTime.now(),
    });
  }

  List<int> _accumulatePlayTime = List.filled(7, 0);
  List<int> get accumulatePlayTime => _accumulatePlayTime;
  set accumulatePlayTime(List<int> newList) {
    _accumulatePlayTime = newList;
    userCheckinCollection.doc(_user?.uid).update({
      'accumulatePlayTime': newList,
      'lastUpdateTime': DateTime.now(),
    });
  }

  bool _haveBonusReward = false;
  bool get haveBonusReward => _haveBonusReward;
  set haveBonusReward(bool value) {
    _haveBonusReward = value;
    notifyListeners();
  }

  void addPlayTime(DateTime start, DateTime end) {
    DateTime startDay =
        DateTime(_cycleStartDay.year, _cycleStartDay.month, _cycleStartDay.day);
    DateTime currentTime = DateTime.now();
    int differenceInDays =
        DateTime(currentTime.year, currentTime.month, currentTime.day)
            .difference(startDay)
            .inDays;
    int seconds = end.difference(start).inSeconds;
    _accumulatePlayTime[differenceInDays.remainder(7)] += seconds;
    isHaveBonusReward();
    if (haveBonusReward) notifyListeners();
  }

  void updateMaxPlayTime(int seconds) {
    DateTime startDay =
        DateTime(_cycleStartDay.year, _cycleStartDay.month, _cycleStartDay.day);
    DateTime currentTime = DateTime.now();
    int differenceInDays =
        DateTime(currentTime.year, currentTime.month, currentTime.day)
            .difference(startDay)
            .inDays;
    // int seconds = end.difference(start).inSeconds;
    _maxPlayTime[differenceInDays.remainder(7)] =
        max(_maxPlayTime[differenceInDays.remainder(7)], seconds);
    isHaveBonusReward();
    if (haveBonusReward) notifyListeners();
  }

  void isHaveBonusReward() {
    bool hasBonus = false;
    if ((_maxPlayTime.any((element) => element >= 30 * 60)) &&
        _bonusRewardCycle[0] == 'unqualification') {
      _bonusRewardCycle[0] = 'uncollected';
      hasBonus = true;
    }

    if ((_accumulatePlayTime.where((element) => element >= 5 * 60)).length >=
            3 &&
        _bonusRewardCycle[1] == 'unqualification') {
      _bonusRewardCycle[1] = 'uncollected';
      hasBonus = true;
    }

    if ((_maxPlayTime.where((element) => element >= 30 * 60)).length >= 3 &&
        _bonusRewardCycle[2] == 'unqualification') {
      _bonusRewardCycle[2] = 'uncollected';
      hasBonus = true;
    }
    bonusRewardCycle = _bonusRewardCycle;
    if (hasBonus) {
      haveBonusReward = true;
    } else {
      haveBonusReward = false;
    }
  }

  /// if user tapped the reward image it will call this functinon to handle
  /// the change in database and return the reward user will get
  void updateRewardStatus(int index) {
    //* if user have logged in but have not claimed the reward
    if (_loginCycle[index] && !_loginRewardCycle[index]) {
      List<bool> tmp = List.from(_loginRewardCycle);
      tmp[index] = true;
      loginRewardCycle = tmp;
      coins += (index + 1) * 100;
    }
    //* to check if no reward
    if (listEquals(_loginCycle, _loginRewardCycle)) {
      haveCheckinReward = false;
    }
  }

  void achieveBonusReward(int index) {
    List<String> list = bonusRewardCycle;
    list[index] = 'collected';
    bonusRewardCycle = list;
    switch (index) {
      case 0:
        coins += 500;
        break;
      case 1:
        coins += 1500;
        break;
      case 2:
        coins += 1500;
        break;
      default:
        break;
    }
    isHaveBonusReward();
  }

  // ----------------------------------------------------------------

  List<RankingUser> _rankingUsers = [];
  get rankingUsers => _rankingUsers;

  RankingUser? _currentUser;
  get currentUser => _currentUser;

  void updateRanking() {
    FirebaseFirestore.instance.collection('global_info').get().then(
      (querySnapshot) {
        _rankingUsers = [];
        for (var docSnapShot in querySnapshot.docs) {
          _rankingUsers.add(
            RankingUser(
              userid: docSnapShot.id,
              username: docSnapShot.data()['user_name'],
              ownedCoins: docSnapShot.data()['coins'],
            ),
          );
        }
        while (_rankingUsers.length < 3) {
          _rankingUsers.add(RankingUser());
        }
        _rankingUsers.sort((a, b) => b.ownedCoins.compareTo(a.ownedCoins));
        _currentUser = _rankingUsers.singleWhere(
          (element) => element.userid == FirebaseAuth.instance.currentUser!.uid,
        );
        notifyListeners();
      },
    );
  }
}
