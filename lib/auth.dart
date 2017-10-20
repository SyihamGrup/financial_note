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
final analytics = new FirebaseAnalytics();

final _googleSignIn = new GoogleSignIn();

Future<FirebaseUser> ensureLoggedIn() async {
  var user = await auth.currentUser();
  if (user != null) return user;

  final prefs = await SharedPreferences.getInstance();
  final method = prefs.getString(kPrefSignInMethod) ?? kPrefSignInGoogle;

  switch (method) {
    case kPrefSignInGoogle:
      final google = await signInWithGoogle();
      if (google == null) return null;
      
      analytics.logLogin();
      final c = await google.authentication;
      user = await auth.signInWithGoogle(idToken: c.idToken, accessToken: c.accessToken);
      return user;
  }

  return null;
}

Future<GoogleSignInAccount> signInWithGoogle() async {
  if (_googleSignIn.currentUser == null) {
    await _googleSignIn.signInSilently();
  }
  if (_googleSignIn.currentUser == null) {
    await _googleSignIn.signIn();
  }
  return _googleSignIn.currentUser;
}

Future<Null> signOut() async {
  return await auth.signOut();
}
