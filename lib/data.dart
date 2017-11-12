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
import 'package:financial_note/src/data/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'src/data/base_data.dart';
export 'src/data/bill.dart';
export 'src/data/book.dart';
export 'src/data/budget.dart';
export 'src/data/note.dart';
export 'src/data/transaction.dart';
export 'src/data/user.dart';

const kMessagingKey = 'AAAA7qN8kBM:APA91bEonGWnktNOzcMHE0Xe9dXYrax8f8qk5hcfcrYFTzFKG7cnO-YOsQgOejXAzAZtcktQWu0j5CPGUCfwtf3fzlFYze9AAEMOKuV5aGA3EDBhexJUZU9BIzMBs37uULgf83G0nksr';

const kUriScheme = 'https';
const kFirebaseHost = 'us-central1-financialnote-d6d95.cloudfunctions.net';
const kMessagingHost = 'fcm.googleapis.com';
const kMessagingPath = '/fcm/send';
const kOpeningBalancePath = '/getOpeningBalance';
const kCalcOpeningBalancePath = '/calcOpeningBalance';

const kNotificationChannel = 'financialnote.adisayoga.com/notification';
const kScheduleNotification = 'schedule_notification';
const kShowNote = 'show_note';

const kIncome = 1;
const kExpense = -1;

// Global variable current book
User currentUser;
Book currentBook;

/// Get node database reference
DatabaseReference getNode(String name, String filterNode) {
  final ref = FirebaseDatabase.instance.reference().child(name);
  if (filterNode == null) return ref;
  return ref.child(filterNode);
}

/// Get book dari firebase user.
Future<Book> getBook(User user) async {
  final book = await getDefaultBook(user.uid);
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(kPrefBookId, book?.id);
  return book;
}

/// Get book saat ini dari preference, atau buat default jika belum ada.
Future<Book> getDefaultBook(String userId) async {
  var book = await _getBookFromPrefs(userId);
  if (book != null) return book;

  book = await Book.of(userId).first();
  if (book != null) return book;

  return await Book.createDefault(userId);
}

/// Get book dari shared preferences.
Future<Book> _getBookFromPrefs(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final bookId = prefs.getString(kPrefBookId);
  if (bookId == null) return null;
  return await Book.of(userId).get(bookId);
}
