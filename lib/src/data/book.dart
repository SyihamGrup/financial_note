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
import 'package:firebase_database/firebase_database.dart';

class Book {
  static const kNodeName = 'books';

  String id;
  String title;
  String descr;

  Book({this.id, this.title, this.descr});

  Book.fromJson(this.id, Map<String, dynamic> json)
    : title = parseString(mapValue(json, 'title')),
      descr = parseString(mapValue(json, 'descr'));

  Book.fromSnapshot(DataSnapshot snapshot)
    : id    = snapshot.key,
      title = parseString(mapValue(snapshot.value, 'title')),
      descr = parseString(mapValue(snapshot.value, 'descr'));

  static Future<Book> first(String userId) async {
    final ref = FirebaseDatabase.instance.reference().child(kNodeName).child(userId);
    final snap = await ref.limitToFirst(1).once();
    if (snap.value == null) return null;

    Book book;
    Map<String, Map<String, dynamic>> items = snap.value;
    items.forEach((key, value) {
      book = new Book.fromJson(key, value);
    });
    return book;
  }

  static Future<Book> get(String userId, String id) async {
    if (id == null) return null;
    final snap = await getNode(userId).child(id).once();
    if (snap.value == null) return null;
    return new Book.fromSnapshot(snap);
  }

  Future<Null> save(String userId) async {
    final node = getNode(userId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;
  }

  static Future<Null> remove(String userId, String id) async {
    final node = getNode(userId);
    await node.child(id).remove();
  }

  static Future<Book> createDefault(String userId) async {
    final data = <String, dynamic>{
      'title' : 'Default',
      'descr' : 'Default book'
    };
    final ref = FirebaseDatabase.instance.reference().child(kNodeName).child(userId);
    final newItem = ref.push();
    await newItem.set(data);

    return new Book.fromJson(newItem.key, data);
  }

  static DatabaseReference getNode(String userId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(userId);
  }

  Map<String, dynamic> toJson({showId: false}) {
    final json = <String, dynamic>{
      'id'    : id,
      'title' : title,
      'descr' : descr,
    };
    if (!showId) json.remove('id');
    return json;
  }
}
