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
import 'dart:convert';

import 'package:financial_note/data.dart';
import 'package:financial_note/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
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

  static Future<List<Transaction>> list(
      String bookId, DateTime dateStart, DateTime dateEnd, openingBalance,
  ) async {
    final ret = new List<Transaction>();
    final snap = await getNode(bookId).orderByChild('date')
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

  static Future<Transaction> get(String bookId, String id) async {
    final snap = await getNode(bookId).child(id).once();
    if (snap.value == null) return null;
    return new Transaction.fromSnapshot(snap);
  }

  Future<Null> save(String bookId) async {
    final existing = id != null ? await Transaction.get(bookId, id) : null;

    final node = getNode(bookId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;

    await _updateBudget(bookId, existing, this);
    await _updateBill(bookId, existing, this);
    await _updateBalance(bookId, existing, this);
  }

  static Future<Null> remove(String bookId, String id) async {
    final existing = await Transaction.get(bookId, id);

    final node = getNode(bookId);
    await node.child(id).remove();

    await _updateBudget(bookId, existing, null);
    await _updateBill(bookId, existing, null);
    await _updateBalance(bookId, existing, null);
  }

  static Future<Null> _updateBudget(
    String bookId, Transaction oldItem, Transaction newItem
  ) async {
    if (oldItem != null && oldItem.budgetId != null) {
      final budget = await Budget.get(bookId, oldItem.budgetId);
      if (budget != null) {
        budget.value += oldItem.value;
        budget.save(bookId);
      }
    }
    if (newItem != null && newItem.budgetId != null) {
      final budget = await Budget.get(bookId, newItem.budgetId);
      if (budget != null) {
        budget.value -= newItem.value;
        budget.save(bookId);
      }
    }
  }

  static Future<Null> _updateBill(
    String bookId, Transaction oldItem, Transaction newItem
  ) async {
    if (oldItem != null && oldItem.billId != null) {
      final bill = await Bill.get(bookId, oldItem.billId);
      if (bill != null) {
        bill.value += oldItem.value;
        bill.save(bookId);
      }
    }
    if (newItem != null && newItem.billId != null) {
      final bill = await Bill.get(bookId, newItem.billId);
      if (bill != null) {
        bill.value -= newItem.value;
        bill.save(bookId);
      }
    }
  }

  static Future<Null> _updateBalance(
    String bookId, Transaction oldItem, Transaction newItem
  ) async {
    if (oldItem != null) {
      final year = oldItem.date.year;
      final month = oldItem.date.month;
      final balance = await Balance.getValue(bookId, year, month);
      Balance.setValue(bookId, year, month, balance - oldItem.value);
    }
    if (newItem != null) {
      final month = newItem.date.year;
      final year = newItem.date.month;
      final balance = await Balance.getValue(bookId, year, month);
      Balance.setValue(bookId, year, month, balance + newItem.value);
    }
  }

  static DatabaseReference getNode(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
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
}

class Balance {
  static const kNodeName = 'balances';
  static const kPeriodFormat = 'yMM';

  String id;
  double value;

  Balance({this.id, this.value : 0.0});

  Balance.fromSnapshot(DataSnapshot snapshot)
    : id = snapshot.key,
      value = parseDouble(snapshot.value);

  int get year {
    if (id == null) return 0;
    return parseInt(id?.substring(0, 4)) ?? 0;
  }

  set year(int value) {
    final sYear = '$value';
    final sMonth = '$month';
    id = sYear.padLeft(4, '0') + sMonth.padLeft(2, '0');
  }

  int get month {
    if (id == null || id.length <= 4) return 0;
    return parseInt(id?.substring(4, 6)) ?? 0;
  }

  set month(int value) {
    final sYear = '$year';
    final sMonth = '$value';
    id = sYear.padLeft(4, '0') + sMonth.padLeft(2, '0');
  }

  static Future<Balance> get(String bookId, String id) async {
    if (id == null) return null;
    final snap = await getNode(bookId).child(id).once();
    if (snap.value == null) return null;
    return new Balance.fromSnapshot(snap);
  }

  static Future<double> getValue(String bookId, int year, int month) async {
    final period = new DateFormat(kPeriodFormat).format(new DateTime(year, month));
    final snap = await getNode(bookId).child(period).once();
    return parseDouble(snap.value);
  }

  static Future<Null> setValue(String bookId, int year, int month, double value) async {
    final period = new DateFormat(kPeriodFormat).format(new DateTime(year, month));
    await getNode(bookId).child(period).set(value);
  }

  void setPeriod(int year, int month) {
    final date = new DateTime(year, month);
    id = new DateFormat(Balance.kPeriodFormat).format(date);
  }

  static Future<double> calculate(String bookId, int year, int month) async {
    final httpClient = createHttpClient();

    final params = <String, dynamic>{
      'bookId' : bookId,
      'year'   : year,
      'month'  : month,
    };
    final response = await httpClient.get(firebaseUri(kCalcOpeningBalancePath, params));

    Map<String, dynamic> json = JSON.decode(response.body);
    return parseDouble(mapValue(json, 'balance'));
  }

  static Future<Null> remove(String bookId, String id) async {
    final node = getNode(bookId);
    await node.child(id).remove();
  }

  static DatabaseReference getNode(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

}
