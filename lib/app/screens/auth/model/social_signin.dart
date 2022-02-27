import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class SocialSignInModel {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> googleSignIns() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.requestScopes(["profile", "email"]);

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await googleSignIn.disconnect();
      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        if (userCredential.user != null)
          return true;
        else
          return false;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> signin(String email, String senha) async {
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: senha);
      if (userCredential.user != null)
        return true;
      else
        return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String senha) async {
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);
      if (userCredential.user != null)
        return true;
      else
        return false;
    } catch (e) {
      return false;
    }
  }
}
