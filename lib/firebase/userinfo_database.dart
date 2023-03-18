import 'package:cloud_firestore/cloud_firestore.dart';

class UserinfoDatabaseService {
  final String docId;
  UserinfoDatabaseService({required this.docId});

  // to record the user info such as coins held by each user
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_basic_info');

  Future createUserInfo({required int coins}) async {
    return await userCollection.doc(docId).set({'coins': 0});
  }

  Stream<QuerySnapshot> get uerInfo {
    return userCollection.snapshots();
  }
}
