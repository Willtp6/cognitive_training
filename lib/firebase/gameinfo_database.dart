import 'package:cloud_firestore/cloud_firestore.dart';

class GameInfoDatabaseService {
  final String docId;
  GameInfoDatabaseService({required this.docId});

  final CollectionReference userGameInfoCollection =
      FirebaseFirestore.instance.collection('user_game_info');

  Future createUserGameInfo() async {
    return await userGameInfoCollection.doc(docId).set({'game1': {}});
  }
/*
  Stream<QuerySnapshot> get uerGameInfo {
    return userGameInfoCollection.snapshots();
  }*/
}
