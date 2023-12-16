import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class GlobalInfoProvider extends ChangeNotifier {
  List<RankingUser> _rankingUsers = [];

  get rankingUsers => _rankingUsers;

  RankingUser? _currentUser;

  get currentUser => _currentUser;

  GlobalInfoProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != null) {
        FirebaseFirestore.instance.collection('global_info').get().then(
          (querySnapshot) {
            // Logger().i('succefully completed');
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
              (element) => element.userid == newUser.uid,
            );
            notifyListeners();
          },
          onError: (e) => Logger().e(e),
        );
      }
    });
  }

  void updateRanking() {
    FirebaseFirestore.instance.collection('global_info').get().then(
      (querySnapshot) {
        Logger().i('succefully completed');
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
      onError: (e) => Logger().e(e),
    );
  }
}

class RankingUser {
  String username;
  String userid;
  int ownedCoins;
  RankingUser(
      {this.username = '未找到玩家',
      this.userid = 'usernotfound',
      this.ownedCoins = 0});
}
