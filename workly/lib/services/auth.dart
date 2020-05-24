import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class AuthBase {
  Stream<User> get onAuthStateChanged;
  Future<User> currentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

class Auth implements AuthBase{

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    } else {
      return User(
        uid: user.uid,
      );
    }
  }

  @override 
  Stream<User> get onAuthStateChanged {
    return FirebaseAuth.instance.onAuthStateChanged.map((user) => _userFromFirebase(user));
  }

  @override
  Future<User> currentUser() async {
    final FirebaseUser user =  await FirebaseAuth.instance.currentUser();
    return _userFromFirebase(user);
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    AuthResult authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    AuthResult authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class User {
  final String uid;

  User({
    @required this.uid
  });
}