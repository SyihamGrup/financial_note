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

class Transaction {
  static const kNodeName = 'transactions';

  String id;
  String billId;
  String budgetId;
  String title;
  DateTime date;
  double value;
  double balance;
  String note;

  Transaction({
    this.id,
    this.billId,
    this.budgetId,
    this.title,
    this.date,
    this.value: 0.0,
    this.balance: 0.0,
    this.note,
  });

  Transaction.fromJson(this.id, Map<String, dynamic> json)
    : billId    = parseString(mapValue(json, 'billId')),
      budgetId  = parseString(mapValue(json, 'budgetId')),
      title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      balance   = parseDouble(mapValue(json, 'balance')),
      note      = parseString(mapValue(json, 'note'));

  Transaction.fromSnapshot(DataSnapshot snapshot)
    : id        = snapshot.key,
      billId    = parseString(mapValue(snapshot.value, 'billId')),
      budgetId  = parseString(mapValue(snapshot.value, 'budgetId')),
      title     = parseString(mapValue(snapshot.value, 'title')),
      date      = parseDate(mapValue(snapshot.value, 'date')),
      value     = parseDouble(mapValue(snapshot.value, 'value')),
      balance   = parseDouble(mapValue(snapshot.value, 'balance')),
      note      = parseString(mapValue(snapshot.value, 'note'));

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  static Future<List<Transaction>> list(
      String bookId, DateTime dateStart, DateTime dateEnd, openingBalance,
  ) async {
    final ret = new List<Transaction>();
    final snap = await ref(bookId).orderByChild('date')
        .startAt(dateStart.toIso8601String()).endAt(dateEnd.toIso8601String())
        .once();
    if (snap.value == null) return ret;

    final items = <Transaction>[];
    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, value) {
      items.add(new Transaction.fromJson(key, value));
    });
    items.sort((a, b) => a.date?.compareTo(b.date) ?? 0);

    var balance = openingBalance;
    items.forEach((item) {
      balance += item.value;
      item.balance = balance;
      ret.insert(0, item);
    });

    return ret;
  }

  Map<String, dynamic> toJson({showId: false, showBalance: false}) {
    final json = <String, dynamic>{
      'id'       : id,
      'billId'   : billId,
      'budgetId' : budgetId,
      'title'    : title,
      'date'     : date?.toIso8601String(),
      'value'    : value,
      'balance'  : balance,
      'note'     : note,
    };
    if (!showId) json.remove('id');
    if (!showBalance) json.remove('balance');
    return json;
  }

  Transaction copyWith({
    String id,
    String billId,
    String budgetId,
    String title,
    DateTime date,
    double value,
    double balance,
    String note,
  }) {
    return new Transaction(
      id       : id       ?? this.id,
      billId   : billId   ?? this.billId,
      budgetId : budgetId ?? this.budgetId,
      title    : title    ?? this.title,
      date     : date     ?? this.date,
      value    : value    ?? this.value,
      balance  : balance  ?? this.balance,
      note     : note     ?? this.note,
    );
  }
}
