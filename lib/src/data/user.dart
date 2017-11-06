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

import 'package:financial_note/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  static const kNodeName = 'users';

  FirebaseUser _firebaseUser;
  String notificationKey;
  List<String> registrationIds;

  User(this._firebaseUser, {
    this.notificationKey,
    this.registrationIds,
  });

  String get uid => _firebaseUser.uid;
  String get displayName => _firebaseUser.displayName;

  static Future<User> get(FirebaseUser user) async {
    final snap = await getNode().child(user.uid).once();
    return new User(user,
      notificationKey: mapValue<String>(snap.value, 'notificationKey'),
      registrationIds: mapValue<List<String>>(snap.value, 'registrationIds'),
    );
  }

  Future<Null> save() async {
    final ref = getNode().child(_firebaseUser.uid);
    await ref.set(toJson());
  }

  static Future<Null> remove(String id) async {
    await getNode().child(id).remove();
  }

  static DatabaseReference getNode() {
    return FirebaseDatabase.instance.reference().child(kNodeName);
  }

  Map<String, dynamic> toJson({showId: false}) {
    return <String, dynamic>{
      'notificationKey' : notificationKey,
      'registrationIds' : registrationIds,
    };
  }
}
