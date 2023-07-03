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
      'registerTime': DateTime.now(),
      'lotteryGameDatabase': {
        'level': 0,
        'digit': 2,
        'doneTutorial': false,
      },
      'pokerGameDatabase': {
        'level': 0,
        'doneTutorial': false,
        'responseTimeList': [],
      },
      'fishingGameDatabase': {
        'level': 0,
        'doneTutorial': false,
      }
    });
  }

  Future<void> createUserCheckinInfo() async {
    await userCheckinCollection.doc(docId).set({
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
