import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordGame {
  RecordGame._();

  static Future<void> recordLotteryGame({
    required int gameLevel,
    required int numberOfDigits,
    required int numOfCorrectAns,
    required int specialRule,
    required DateTime end,
    required DateTime start,
    required List<int> answer,
    required List<int> playerInput,
  }) async {
    await setLastUpdateTime();
    User? user = FirebaseAuth.instance.currentUser;
    //record the game info
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user?.uid)
        .collection('lottery_game')
        .doc(DateTime.now().toString());
    if (gameLevel < 2) {
      return reference.set({
        'gameDifficulties': gameLevel + 1,
        'numOfDigits': numberOfDigits,
        'accuracy': numOfCorrectAns / numberOfDigits,
        'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
        'answer': answer,
        'playerInput': playerInput,
      });
    } else {
      List<String> ruleStrings = ['even', 'max', 'min', 'odd'];
      // return reference.set({
      //   'game_record': {
      //     'gameDifficulties': gameLevel + 1,
      //     'numOfDigits': numberOfDigits,
      //     'specialRule': ruleStrings[specialRule],
      //     'accuracy': numOfCorrectAns / numberOfDigits,
      //     'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
      //     'answer': answer,
      //     'playerInput': playerInput,
      //   }
      // });
      return reference.set({
        'gameDifficulties': gameLevel + 1,
        'numOfDigits': numberOfDigits,
        'specialRule': ruleStrings[specialRule],
        'accuracy': numOfCorrectAns / numberOfDigits,
        'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
        'answer': answer,
        'playerInput': playerInput,
      });
    }
  }

  static Future<void> recordFishingGame({
    required int gameLevel,
    required DateTime start,
    required DateTime end,
    required String type,
  }) async {
    await setLastUpdateTime();
    User? user = FirebaseAuth.instance.currentUser;
    //record the game info
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user?.uid)
        .collection('fishing_game')
        .doc(DateTime.now().toString());
    return reference
        .set({
          'gameDifficulties': gameLevel + 1,
          'type': type,
          'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
        })
        .then((value) => Logger().d(user?.uid))
        .catchError((error) => Logger().d(error.message));
  }

  static Future<void> recordPokerGame({
    required int gameLevel,
    required String result,
    required DateTime end,
    required DateTime start,
    required String computerRank,
    required String playerRank,
    required String computerSuit,
    required String playerSuit,
  }) async {
    await setLastUpdateTime();
    User? user = FirebaseAuth.instance.currentUser;
    //record the game info
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user?.uid)
        .collection('poker_game')
        .doc(DateTime.now().toString());
    return reference
        .set({
          'gameDifficulties': gameLevel + 1,
          'result': result,
          'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
          'computerCard': computerSuit + computerRank,
          'playererCard': playerSuit + playerRank,
        })
        .then((value) => Logger().d(user?.uid))
        .catchError((error) => Logger().d(error.message));
  }

  static Future<void> recordRoutePlanningGame({
    required List<int> timeToEachHalfwayPoint,
    required int nonTargetError,
    required int repeatedError,
    required int numOfTargets,
    required int mapIndex,
    required int gameDifficulties,
    required DateTime start,
    required DateTime end,
    required String result,
  }) async {
    await setLastUpdateTime();
    User? user = FirebaseAuth.instance.currentUser;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user?.uid)
        .collection('route_planning_game')
        .doc(DateTime.now().toString());
    return reference
        .set({
          'timeToEachHalfwayPoint': timeToEachHalfwayPoint,
          'nonTargetError': nonTargetError,
          'repeatedError': repeatedError,
          'numOfTargets': numOfTargets,
          'mapIndex': mapIndex,
          'gameDifficulties': gameDifficulties,
          'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
          'result': result,
        })
        .whenComplete(() => Logger().d(user?.uid))
        .catchError((error) => Logger().d(error));
  }

  static Future<void> setLastUpdateTime() async {
    Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();
    final pref = await instanceFuture;
    pref.setString('timeOfLastDatabaseUpdate', DateTime.now().toString());
  }
}
