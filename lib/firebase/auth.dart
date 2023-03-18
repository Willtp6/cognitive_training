import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:cognitive_training/models/user.dart';
import 'package:logger/logger.dart';

class AuthService {
  // create an Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj on FirebaseUser
  LocalUser? _userFromFirebaseUser(User? user) {
    //return LocalUser(uid: user!.uid);
    return user != null ? LocalUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<LocalUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in custom token

  // sign in anonymous
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & passwd
  /*
  Future registerWithEmailAndPasswd(String uid) async {
    String email = "$uid@gmail.com";
    String passwd = uid.padLeft(6, '0');
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: passwd);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (authError) {
      //throw CustomAuthException(authError.code, authError.message!);
      if (authError.code == 'email-already-in-use') {
        signInWithEmailAndPasswd(uid);
      }
    } catch (e) {
      var logger = Logger();
      logger.d(e.toString());
      print(e.toString());
      return null;
    }
  }*/

  // sign in with email & passwd
  // code in here have some loophole because the gmail account is not really exists
  // thus if any user want to reset their passwd or identify their account will fail
  // although this app doesn't provide these kind of function
  // but if there's any one  want to add new functions should becareful
  /*
  Future signInWithEmailAndPasswd(String uid) async {
    String email = "$uid@gmail.com";
    String passwd = uid.padLeft(6, '0');
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: passwd);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (authError) {
      //throw CustomAuthException(authError.code, authError.message!);
      print(authError.code);
      if (authError.code == 'user-not-found') {
        registerWithEmailAndPasswd(uid);
      }
    } catch (e) {
      //throw CustomException(errorMessage: "Unknown Error");
      print(e.toString());
    }
  }*/

  Future loginOrCreateAccountWithId(String uid) async {
    String email = "$uid@gmail.com";
    String passwd = uid.padLeft(6, '0');
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: passwd);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (authError) {
      //throw CustomAuthException(authError.code, authError.message!);
      if (authError.code == 'user-not-found') {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: email, password: passwd);
        User? user = result.user;
        return _userFromFirebaseUser(user);
      }
    } catch (e) {
      //throw CustomException(errorMessage: "Unknown Error");
      print(e.toString());
    }
  }

  // sign out
  Future signOut() async {
    try {
      print('signed out');
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
