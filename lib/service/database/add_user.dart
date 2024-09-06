import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUser{
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Future<void> emailUser( String email, String name,
      ) {
    // Kullanıcı ID'sini belirtmek için `.doc(userId)` kullanılır
    return users
        .doc(email)
        .set({
      'email': email,
      'name': name,
      'user_id': FirebaseAuth.instance.currentUser?.uid,
      'creation_time': FirebaseAuth
          .instance.currentUser?.metadata.creationTime
          .toString().substring(0,10),

      'auth_type': "mail",
      'platform': Platform.isAndroid ? 'android' : 'ios',
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}