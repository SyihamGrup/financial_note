/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library data;

import 'dart:async';

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'src/data/balance.dart';
export 'src/data/bill.dart';
export 'src/data/book.dart';
export 'src/data/budget.dart';
export 'src/data/note.dart';
export 'src/data/transaction.dart';

const kFirebaseUriScheme = 'https';
const kFirebaseHost = 'us-central1-financialnote-d6d95.cloudfunctions.net';

const kOpeningBalancePath = '/getOpeningBalance';
const kCalcOpeningBalancePath = '/calcOpeningBalance';

// Global variable current book
FirebaseUser currentUser;
Book currentBook;

/// Get firebase uri
Uri firebaseUri(String path, Map<String, dynamic> params, {
  String scheme: kFirebaseUriScheme,
  String host: kFirebaseHost,
}) {
  return new Uri(
    scheme: scheme,
    host:   host,
    path:   path,
    queryParameters: params,
  );
}

/// Get book saat ini dari preference, atau buat default jika belum ada.
Future<Book> getDefaultBook(String userId) async {
  var book = await _getBookFromPrefs(userId);
  if (book != null) return book;

  book = await Book.first(userId);
  if (book != null) return book;

  return await Book.createDefault(userId);
}

/// Get book dari shared preferences.
Future<Book> _getBookFromPrefs(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final bookId = prefs.getString(kPrefBookId);
  if (bookId == null) return null;

  final snap = await Book.ref(userId).child(bookId).once();
  if (snap.value == null) return null;

  return new Book.fromJson(snap.key, snap.value);
}
