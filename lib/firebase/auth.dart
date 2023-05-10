import 'package:cognitive_training/firebase/userinfo_database.dart';
import 'package:cognitive_training/models/user_checkin_provider.dart';
import 'package:cognitive_training/models/user_info_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cognitive_training/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AuthService {
  // create an Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var logger = Logger();
  final UserInfoProvider userInfoProvider = UserInfoProvider();
  final UserCheckinProvider userCheckinProvider = UserCheckinProvider();

  // // create user obj on FirebaseUser
  // LocalUser? _userFromFirebaseUser(User? user) {
  //   return user != null ? LocalUser(uid: user.uid) : null;
  // }

  // // auth change user stream in main defined stream provider
  // Stream<LocalUser?> get userStream {
  //   return _auth.authStateChanges().map(_userFromFirebaseUser);
  // }

  // sign in with email & passwd
  // code in here have some loophole because the gmail account is not really exists
  // thus if any user want to reset their passwd or identify their account will fail
  // although this app doesn't provide these kind of function
  // but if there's any one want to add new functions should be careful
  Future loginOrCreateAccountWithId(String uid, String userName) async {
    String email = "$uid@gmail.com";
    //String passwd = uid.padLeft(6, '0');
    String passwd = userName.padLeft(6, '0');
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: passwd);
      return result.user?.uid;
    } on FirebaseAuthException catch (authError) {
      if (authError.code == 'user-not-found') {
        try {
          UserCredential result = await _auth.createUserWithEmailAndPassword(
              email: email, password: passwd);
          result.user?.updateDisplayName(userName);
          // create new user info database
          await UserDatabaseService(docId: result.user!.uid, userName: userName)
              .createUserInfo();
          userInfoProvider.updateUserData(result.user);
          userCheckinProvider.updateData(result.user);
          return result.user?.uid;
        } catch (error) {
          return error;
        }
      } else {
        Logger().w(authError.code);
        return authError;
      }
    } catch (error) {
      return error;
    }
  }

  Future login(String uid) async {
    String email = "$uid@gmail.com";
    String passwd = uid.padLeft(6, '0');
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: passwd);
      return result.user?.uid;
    } on FirebaseAuthException catch (authError) {
      return authError;
    } catch (error) {
      return error;
    }
  }

  // sign out
  Future signOut() async {
    try {
      logger.v('signed out');
      return await _auth.signOut();
    } catch (e) {
      logger.v(e.toString());
      return null;
    }
  }
}
