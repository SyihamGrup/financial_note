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
import 'package:firebase_database/firebase_database.dart';

class Book implements Data {
  static const kNodeName = 'books';

  final String userId;

  String id;
  String title;
  String descr;

  Book(this.userId, {this.id, this.title, this.descr});

  Book.fromJson(this.userId, this.id, Map<String, dynamic> json)
    : title = parseString(mapValue(json, 'title')),
      descr = parseString(mapValue(json, 'descr'));

  Book.fromSnapshot(String userId, DataSnapshot snapshot)
    : this.fromJson(userId, snapshot.key, snapshot.value);

  static Book of(String userId) {
    return new Book(userId);
  }

  Future<Book> first() async {
    final node = getNode(kNodeName, userId);
    final snap = await node.limitToFirst(1).once();
    if (snap.value == null) return null;

    Book book;
    Map<String, Map<String, dynamic>> items = snap.value;
    items.forEach((key, value) {
      book = new Book.fromJson(userId, key, value);
    });
    return book;
  }

  Future<Book> get(String id) async {
    if (id == null) return null;
    final snap = await getNode(kNodeName, userId).child(id).once();
    if (snap.value == null) return null;
    return new Book.fromSnapshot(userId, snap);
  }

  Future<Null> save() async {
    final node = getNode(kNodeName, userId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;
  }

  Future<Null> removeById(String id) async {
    if (id == null) return;
    await getNode(kNodeName, userId).child(id).remove();
  }

  Future<Null> remove() async {
    await removeById(id);
  }

  static Future<Book> createDefault(String userId) async {
    final data = <String, dynamic>{
      'title' : 'Default',
      'descr' : 'Default book'
    };
    final node = getNode(kNodeName, userId);
    final newItem = node.push();
    await newItem.set(data);

    return new Book.fromJson(userId, newItem.key, data);
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
