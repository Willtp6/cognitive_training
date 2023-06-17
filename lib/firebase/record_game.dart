import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class RecordLotteryGame {
  Future<void> recordGame({
    required int gameLevel,
    required int numberOfDigits,
    required int numOfCorrectAns,
    required int specialRule,
    required DateTime end,
    required DateTime start,
    required List<int> answer,
    required List<int> playerInput,
  }) {
    User? user = FirebaseAuth.instance.currentUser;
    //record the game info
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user?.uid)
        .collection('lottery_game')
        .doc(DateTime.now().toString());
    if (gameLevel < 2) {
      return reference.set({
        'game_record': {
          'gameDifficulties': gameLevel + 1,
          'numOfDigits': numberOfDigits,
          'accuracy': numOfCorrectAns / numberOfDigits,
          'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
          'answer': answer,
          'playerInput': playerInput,
        }
      });
    }
    // .then((value) => Logger().d(user?.uid))
    // .catchError((error) => Logger().d(error.message));
    else {
      List<String> ruleStrings = ['even', 'max', 'min', 'odd'];
      return reference.set({
        'game_record': {
          'gameDifficulties': gameLevel + 1,
          'numOfDigits': numberOfDigits,
          'specialRule': ruleStrings[specialRule],
          'accuracy': numOfCorrectAns / numberOfDigits,
          'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
          'answer': answer,
          'playerInput': playerInput,
        }
      });
    }
  }
}

class RecordFishingGame {}

class RecordPokerGame {
  Future<void> recordGame(
      {required int gameLevel,
      required String result,
      required DateTime end,
      required DateTime start}) {
    User? user = FirebaseAuth.instance.currentUser;
    //record the game info
    DocumentReference reference = FirebaseFirestore.instance
        .collection('user_game_info')
        .doc(user?.uid)
        .collection('poker_game')
        .doc(DateTime.now().toString());
    return reference
        .set({
          'game_record': {
            'gameDifficulties': gameLevel + 1,
            'result': result,
            'responseTime(Milliseconds)': end.difference(start).inMilliseconds,
          }
        })
        .then((value) => Logger().d(user?.uid))
        .catchError((error) => Logger().d(error.message));
  }
}
