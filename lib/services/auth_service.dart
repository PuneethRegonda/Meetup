import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetup/services/user_services.dart';
import 'package:meetup/src/result.dart';
import 'package:meetup/src/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map(_userFromFirebaseUser);
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult authresult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Result result = Result();
      result.data = await UserServices().fetchUser(authresult.user.uid);
      result.isSuccess = result.data != null;
      return result;
    } catch (error) {
      print(error.toString());
      return Result();
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password,String name) async {
    if(name== null || name.isEmpty) return; 
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      //  https: methods
      if (user != null){
          Firestore.instance.collection("users").document(user.uid).setData({
                  "name":name,
                  "date": DateTime.now().toIso8601String(),
                  "interests": [],
                  'requests':{},
                  'friends':{}
                });
      }

      Result res = Result();
      res.data = user;
      res.isSuccess = user != null;
      return res;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
