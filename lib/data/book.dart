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

import 'package:financial_note/data/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _db = FirebaseDatabase.instance.reference();

class Book {
  static const nodeName = 'books';

  final String id;
  final String name;
  final String description;

  Book({this.id, this.name, this.description});

  static DatabaseReference ref(String userId) {
    return _db.child(nodeName).child(userId);
  }

  /// Get book saat ini dari preference, atau buat default jika belum ada.
  static Future<Book> getDefault(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    Book book = await _getFromPrefs(userId);
    if (book != null) return book;

    book = await _getFirstItem(userId);
    if (book != null) {
      prefs.setString(Config.kBookId, book.id);
      return book;
    }

    book = await _createDefault(userId);
    prefs.setString(Config.kBookId, book.id);
    return book;
  }

  static Future<Book> _getFromPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookId = prefs.getString(Config.kBookId);
    if (bookId == null) return null;

    final item = await ref(userId).child(bookId).once();
    if (item.value == null) return null;

    return new Book.fromJson(item.key, item.value);
  }

  static Future<Book> _getFirstItem(String userId) async {
    final item = await ref(userId).limitToFirst(1).once();
    if (item.value == null) return null;

    Book book;
    item.value.forEach((key, value) {
      book = new Book.fromJson(key, value);
    });
    return book;
  }

  static Future<Book> _createDefault(String userId) async {
    final data = <String, dynamic>{
      'name': 'Default',
      'description': 'Default book',
    };
    final newItem = ref(userId).push();
    await newItem.set(data);

    return new Book.fromJson(newItem.key, data);
  }

  Book.fromJson(String id, Map<String, dynamic> json)
      : this.id = id,
        this.name = json != null && json.containsKey('name') ? json['name'] : null,
        this.description = json != null && json.containsKey('description') ? json['description'] : null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
    };
  }

}
