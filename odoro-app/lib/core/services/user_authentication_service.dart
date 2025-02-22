import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/* Firebase Service management of Firebase User Logins */
class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Signs in a Firebase User with the 2 required field
  /// email, password
  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      debugPrint("successfully logged in!");
      return "Welcome back " + email + "!";
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message.toString();
    }
  }

  /// register a Firebase User with the 2 required field
  /// email, password
  Future<String> signUp(
      {required String email,
      required String password,
      required String username}) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) => result.user?.updateDisplayName(username));
      //signOut();
      debugPrint(_firebaseAuth.currentUser?.email.toString());
      await _firebaseAuth.currentUser?.sendEmailVerification();
      debugPrint("successfully signed up!");
      return "success";
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message.toString();
    }
  }

  Future<String> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "An E-Mail to reset your password was send to you!";
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message.toString();
    }
  }

  Future<String> deleteAccount(User user) async {
    try {
      await user.delete();
      return "Your account was successfully deleted. If you go back you have to login with another account or you have to create a new one";
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message.toString();
    }
  }
}
