import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class GlobalInfoProvider extends ChangeNotifier {
  late List<RankingUser> rankingUsers;

  GlobalInfoProvider() {
    FirebaseFirestore.instance
        .collection('global_info')
        .doc('ranking')
        .get()
        .then((doc) {
      List<dynamic> userList = doc.data()!['ranking_user'];
      Logger().d(userList);
      userList.sort((a, b) {
        return a['ownedCoins'] < b['ownedCoins']
            ? a['ownedCoins']
            : b['ownedCoins'];
      });
      Logger().d(userList);
      // for (var item in userList.reversed) {
      //   rankingUsers.add(RankingUser(
      //     username: item['username'],
      //     userid: item['userid'],
      //     ownedCoins: item['ownedCoins'],
      //   ));
      // }
      rankingUsers = userList.reversed.map((item) {
        return RankingUser(
          username: item['username'],
          userid: item['userid'],
          ownedCoins: item['ownedCoins'],
        );
      }).toList();
    });
  }

  void updateRanking() {}

  void uploadRanking(String name, String userId, int ownedCoins) {
    RankingUser userToUpdate = rankingUsers.firstWhere(
      (element) => element.userid == userId,
      orElse: () => RankingUser(),
    );
    Logger().d(userToUpdate);
    //* if user is not exist
    if (userToUpdate.userid == 'usernotfound') {
      rankingUsers.add(RankingUser(
        username: name,
        userid: userId,
        ownedCoins: ownedCoins,
      ));
    } else {
      userToUpdate.ownedCoins = ownedCoins;
    }
    FirebaseFirestore.instance.collection('global_info').doc('ranking').update({
      'ranking_user': rankingUsers.map((e) => {
            'username': e.username,
            'userid': e.userid,
            'ownedCoins': e.ownedCoins,
          })
    });
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
