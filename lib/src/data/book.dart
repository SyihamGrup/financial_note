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

import 'package:firebase_database/firebase_database.dart';

class Book {
  static const kNodeName = 'books';

  final String id;
  final String title;
  final String descr;

  const Book({this.id, this.title, this.descr});

  Book.fromJson(this.id, Map<String, dynamic> json)
    : title = json != null && json.containsKey('title') ? json['title'] : null,
      descr = json != null && json.containsKey('descr') ? json['descr'] : null;

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

  static DatabaseReference ref(String userId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(userId);
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title' : title,
      'descr' : descr,
    };
  }

  Book copyWith({
    String id,
    String title,
    String descr,
  }) {
    return new Book(
      id    : id    ?? this.id,
      title : title ?? this.title,
      descr : descr ?? this.descr,
    );
  }

}
