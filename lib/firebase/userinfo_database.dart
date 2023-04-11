import 'package:cloud_firestore/cloud_firestore.dart';

class UserinfoDatabaseService {
  final String docId;
  UserinfoDatabaseService({required this.docId});

  // to record the user info such as coins held by each user
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('user_basic_info');

  Future createUserInfo() async {
    return await userInfoCollection.doc(docId).set({
      'coins': 1200,
      'registerTime': DateTime.now(),
      'lastLoginTime': DateTime.now(),
      'lastUpdateTime': DateTime.now(),
      'continuousLoginDays': 0,
      'loginCycle': [true, false, false, false, false, false, false],
      'loginRewardRecord': [false, false, false, false, false, false, false],
      'lotteryGameDatabase': {
        'level': 0,
        'digit': 2,
        'doneTutorial': false,
      },
      'pokerGameDatabase': {
        'level': 0,
        'doneTutorial': false,
      },
    });
  }

  Stream<QuerySnapshot> get uerInfo {
    return userInfoCollection.snapshots();
  }
}
