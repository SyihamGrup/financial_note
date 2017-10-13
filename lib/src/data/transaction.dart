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
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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
    @required this.title,
    @required this.date,
    @required this.value,
    this.balance: 0.0,
    this.note,
  });

  Transaction.fromJson(this.id, Map<String, dynamic> json)
    : billId    = json != null && json.containsKey('billId')   ? json['billId']               : null,
      budgetId  = json != null && json.containsKey('budgetId') ? json['budgetId']             : null,
      title     = json != null && json.containsKey('title')    ? json['title']                : null,
      date      = json != null && json.containsKey('date')     ? DateTime.parse(json['date']) : null,
      value     = json != null && json.containsKey('value')    ? parseDouble(json['value'])   : 0.0,
      balance   = json != null && json.containsKey('balance')  ? parseDouble(json['balance']) : 0.0,
      note      = json != null && json.containsKey('note')     ? json['note']                 : null;

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  static Future<List<Transaction>> list(
      String bookId, DateTime dateStart, DateTime dateEnd, openingBalance,
  ) async {
    final formatter = new DateFormat('yyyy-MM-dd');
    final ret = new List<Transaction>();

    ret.add(new Transaction(
      title   : 'Opening Balance',
      date    : dateStart,
      value   : openingBalance,
      balance : openingBalance,
    ));

    final snap = await ref(bookId)
        .orderByChild('paidDate')
        .startAt(formatter.format(dateStart), key: 'paidDate')
        .endAt(formatter.format(dateEnd), key: 'paidDate')
        .once();

    if (snap.value == null) return ret;

    var balance = openingBalance;
    Map<String, Map<String, dynamic>> items = snap.value;
    items.forEach((key, item) {
      balance += item.containsKey('value') ? parseDouble(item['value']) : 0.0;
      item['balance'] = balance;
      ret.add(new Transaction.fromJson(key, item));
    });

    return ret;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'billId'   : billId,
      'budgetId' : budgetId,
      'title'    : title,
      'date'     : new DateFormat('yyyy-MM-dd').format(date),
      'value'    : value,
      'balance'  : balance,
      'note'     : note,
    };
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
