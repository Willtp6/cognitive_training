import 'package:cognitive_training/firebase/userinfo_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cognitive_training/models/user.dart';
import 'package:logger/logger.dart';

class AuthService {
  // create an Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var logger = Logger();

  // create user obj on FirebaseUser
  LocalUser? _userFromFirebaseUser(User? user) {
    return user != null ? LocalUser(uid: user.uid) : null;
  }

  // auth change user stream in main defined stream provider
  Stream<LocalUser?> get userStream {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in with email & passwd
  // code in here have some loophole because the gmail account is not really exists
  // thus if any user want to reset their passwd or identify their account will fail
  // although this app doesn't provide these kind of function
  // but if there's any one  want to add new functions should becareful
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
        // create new database with initial amount of coins is 0
        await UserinfoDatabaseService(docId: user!.uid)
            .createUserInfo(coins: 0);
        return _userFromFirebaseUser(user);
      }
    } catch (e) {
      //throw CustomException(errorMessage: "Unknown Error");
      logger.v(e.toString());
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
