import 'package:cloud_firestore/cloud_firestore.dart';

class UserinfoDatabaseService {
  final String docId;
  UserinfoDatabaseService({required this.docId});

  // to record the user info such as coins held by each user
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('user_basic_info');

  Future createUserInfo({required int coins}) async {
    return await userInfoCollection.doc(docId).set({
      'coins': coins,
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
