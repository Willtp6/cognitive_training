import 'package:cloud_firestore/cloud_firestore.dart';

class UserinfoDatabaseService {
  final String docId;
  UserinfoDatabaseService({required this.docId});

  // to record the user info such as coins held by each user
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('user_basic_info');

  Future createUserInfo({required int coins}) async {
    return await userInfoCollection.doc(docId).set({
      'coins': 0,
      'doneTutorial_1': false,
      'doneTutorial_2': false,
      'doneTutorial_3': false,
      'doneTutorial_4': false,
    });
  }

  Stream<QuerySnapshot> get uerInfo {
    return userInfoCollection.snapshots();
  }
}
