import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserInfoProvider with ChangeNotifier {
  final user = FirebaseAuth.instance.currentUser;
  late int _coins;
  late bool _doneTutorial_1;
  late bool _doneTutorial_2;
  late bool _doneTutorial_3;
  late bool _doneTutorial_4;

  UserInfoProvider() {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(user?.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        _coins = doc.data()!['coins'];
        _doneTutorial_1 = doc.data()!['doneTutorial_1'];
      } else {
        _coins = 0;
      }
      notifyListeners();
    });
  }

  int get coins => _coins;
  bool get doneTutorial_1 => _doneTutorial_1;
  bool get doneTutorial_2 => _doneTutorial_2;
  bool get doneTutorial_3 => _doneTutorial_3;
  bool get doneTutorial_4 => _doneTutorial_4;

  set coins(int value) {
    _coins = value;
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(user?.uid)
        .update({'coins': _coins}).then((value) {
      Logger().d(user?.uid);
      notifyListeners();
    });
  }

  set doneTutorial_1(bool value) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(user?.uid)
        .update({'doneTutorial_1': true}).then((value) => null);
  }

  set doneTutorial_2(bool value) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(user?.uid)
        .update({'doneTutorial_2': true}).then((value) => null);
  }

  set doneTutorial_3(bool value) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(user?.uid)
        .update({'doneTutorial_3': true}).then((value) => null);
  }

  set doneTutorial_4(bool value) {
    FirebaseFirestore.instance
        .collection('user_basic_info')
        .doc(user?.uid)
        .update({'doneTutorial_4': true}).then((value) => null);
  }
}
