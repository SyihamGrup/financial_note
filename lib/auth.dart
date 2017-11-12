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
import 'dart:convert';

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/src/data/user.dart';
import 'package:financial_note/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final auth = FirebaseAuth.instance;
final analytics = new FirebaseAnalytics();

final googleSignIn = new GoogleSignIn();
final messaging = new FirebaseMessaging();

Future<User> ensureLoggedIn() async {
  var user = await auth.currentUser();
  if (user != null) return await User.get(user);

  final prefs = await SharedPreferences.getInstance();
  final method = prefs.getString(kPrefSignInMethod) ?? kPrefSignInGoogle;

  switch (method) {
    case kPrefSignInGoogle:
      final google = await signInWithGoogle();
      if (google == null) return null;
      
      analytics.logLogin();
      final c = await google.authentication;
      user = await auth.signInWithGoogle(idToken: c.idToken, accessToken: c.accessToken);
      return await User.get(user);
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

Future<Map<String, dynamic>> addDeviceGroup(User user) async {
  final httpClient = createHttpClient();
  final uri = getUri(kMessagingHost, kMessagingPath);
  Map<String, dynamic> data;
  if (user.notificationKey == null) {
    data = {
      'operation': 'create',
      'notification_key_name': user.uid,
      'registration_ids': ['4', '8', '15', '16', '23', '42']
    };
  } else {
    data = {
      'operation': 'add',
      'notification_key_name': user.uid,
      'notification_key': user.notificationKey,
      'registration_ids': ['4'],
    };
  }
  final response = await httpClient.post(uri, body: data.toString());
  return JSON.decode(response.body);
}
