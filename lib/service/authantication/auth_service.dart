import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AuthService{
  final firebaseAuth = FirebaseAuth.instance;
  Future<User?> createUserWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    final userCredentials = await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredentials.user;
  }
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredentials = await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return userCredentials.user;
  }
}