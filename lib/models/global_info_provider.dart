import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class GlobalInfoProvider extends ChangeNotifier {
  List<RankingUser> _rankingUsers = [];

  get rankingUsers => _rankingUsers;

  RankingUser? _currentUser;

  get currentUser => _currentUser;

  GlobalInfoProvider() {
    // FirebaseFirestore.instance
    //     .collection('global_info')
    //     .doc('ranking')
    //     .get()
    //     .then((doc) {
    //   // List<dynamic> userList = doc.data()!['ranking_user'];
    //   // Logger().d(userList);
    //   // userList.sort((a, b) {
    //   //   return a['ownedCoins'] < b['ownedCoins']
    //   //       ? a['ownedCoins']
    //   //       : b['ownedCoins'];
    //   // });
    //   // Logger().d(userList);
    //   // for (var item in userList.reversed) {
    //   //   rankingUsers.add(RankingUser(
    //   //     username: item['username'],
    //   //     userid: item['userid'],
    //   //     ownedCoins: item['ownedCoins'],
    //   //   ));
    //   // }
    //   // rankingUsers = userList.reversed.map((item) {
    //   //   return RankingUser(
    //   //     username: item['username'],
    //   //     userid: item['userid'],
    //   //     ownedCoins: item['ownedCoins'],
    //   //   );
    //   // }).toList();
    // });

    FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser != null) {
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

  // void uploadRanking(String name, String userId, int ownedCoins) {
  //   RankingUser userToUpdate = rankingUsers.firstWhere(
  //     (element) => element.userid == userId,
  //     orElse: () => RankingUser(),
  //   );
  //   Logger().d(userToUpdate);
  //   //* if user is not exist
  //   if (userToUpdate.userid == 'usernotfound') {
  //     rankingUsers.add(RankingUser(
  //       username: name,
  //       userid: userId,
  //       ownedCoins: ownedCoins,
  //     ));
  //   } else {
  //     userToUpdate.ownedCoins = ownedCoins;
  //   }
  //   FirebaseFirestore.instance.collection('global_info').doc('ranking').update({
  //     'ranking_user': rankingUsers.map((e) => {
  //           'username': e.username,
  //           'userid': e.userid,
  //           'ownedCoins': e.ownedCoins,
  //         })
  //   });
  // }
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
