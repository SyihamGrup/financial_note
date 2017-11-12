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

import 'package:financial_note/data.dart';
import 'package:financial_note/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  static const kNodeName = 'users';

  FirebaseUser _firebaseUser;
  String notificationKey;
  List<String> registrationIds;

  User(FirebaseUser firebaseUser, {
    this.notificationKey,
    this.registrationIds,
  }) : _firebaseUser = firebaseUser;

  String get uid => _firebaseUser.uid;
  String get displayName => _firebaseUser.displayName;
  String get email => _firebaseUser.email;

  static Future<User> get(FirebaseUser user) async {
    final snap = await getNode(kNodeName, null).child(user.uid).once();
    if (snap.value != null) {
      return new User(user,
        notificationKey: valueOf<String>(snap.value, 'notificationKey'),
        registrationIds: valueOf<List<String>>(snap.value, 'registrationIds'),
      );
    } else {
      return new User(user);
    }
  }

  Future<Null> save() async {
    final ref = getNode(kNodeName, null).child(_firebaseUser.uid);
    await ref.set(toJson());
  }

  static Future<Null> remove(String id) async {
    if (id == null) return;
    await getNode(kNodeName, null).child(id).remove();
  }

  Map<String, dynamic> toJson({showId: false}) {
    return {
      'notificationKey' : notificationKey,
      'registrationIds' : registrationIds,
    };
  }
}
