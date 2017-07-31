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

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();

Future<Null> ensureLoggedIn() async {
  var user = googleSignIn.currentUser;
  if (user == null) {
   user = await googleSignIn.signInSilently();
  }
  if (user == null) {
   await googleSignIn.signIn();
   analytics.logLogin();
  }
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    var credentials = await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }
}
