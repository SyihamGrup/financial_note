/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'dart:async';

import 'package:financial_note/config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();

bool isSignedIn() {
  return auth.currentUser != null;
}

Future<FirebaseUser> ensureLoggedIn() async {
  if (isSignedIn()) return auth.currentUser;

  final prefs = await SharedPreferences.getInstance();
  final method = prefs.getString(kPrefSignInMethod) == kPrefSignInGoogle ? SignInMethod.google : null;

  switch (method) {
    case SignInMethod.google:
      final user = await signInWithGoogle();
      if (user == null) return null;
      
      analytics.logLogin();
      final c = await user.authentication;
      await auth.signInWithGoogle(idToken: c.idToken, accessToken: c.accessToken);
      return auth.currentUser;
  }

  return null;
}

Future<GoogleSignInAccount> signInWithGoogle() async {
  if (googleSignIn.currentUser == null) {
    await googleSignIn.signInSilently();
  }
  if (googleSignIn.currentUser == null) {
    await googleSignIn.signIn();
  }
  return googleSignIn.currentUser;
}

Future<Null> signOut() async {
  return await auth.signOut();
}
