import 'package:cloud_firestore/cloud_firestore.dart';

class UserDatabaseService {
  final String docId;
  final String userName;
  UserDatabaseService({required this.docId, required this.userName});

  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('user_basic_info');
  final CollectionReference userCheckinCollection =
      FirebaseFirestore.instance.collection('user_checkin_info');

  Future<void> createUserBasicInfo() async {
    await userInfoCollection.doc(docId).set({
      'coins': 1200,
      'userName': userName,
      'lotteryGameDatabase': {
        'level': 0,
        'digit': 2,
        'historyContinuousWin': 0,
        'historyContinuousLose': 0,
        'doneTutorial': false,
      },
      'pokerGameDatabase': {
        'level': 0,
        'historyContinuousWin': 0,
        'historyContinuousLose': 0,
        'doneTutorial': false,
        'responseTimeList': [],
      },
      'fishingGameDatabase': {
        'level': 0,
        'historyContinuousWin': 0,
        'historyContinuousLose': 0,
        'doneTutorial': false,
      },
      'routePlanningGameDatabase': {
        'level': 0,
        'historyContinuousWin': 0,
        'historyContinuousLose': 0,
        'doneTutorial': false,
        'responseTimeList': [],
      }
    });
  }

  Future<void> createUserCheckinInfo() async {
    await userCheckinCollection.doc(docId).set({
      'registerTime': DateTime.now(),
      'lastLoginTime': DateTime.now(),
      'loginCycle': List.generate(7, (index) => false),
      'loginRewardCycle': List.generate(7, (index) => false),
      'weeklyRewardCycle': List.generate(4, (index) => false),
      'cycleStartDay': DateTime.now(),
      'accumulatePlayTime': List.generate(7, (index) => 0),
      'currentWeek': 0,
    });
  }
}
