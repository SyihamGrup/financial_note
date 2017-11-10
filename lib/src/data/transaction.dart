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

class Transaction implements Data {
  static const kNodeName = 'transactions';

  final String bookId;

  String id;
  String billId;
  String budgetId;
  String title;
  DateTime date;
  double value;
  double balance;
  String note;

  Transaction(this.bookId, {
    this.id,
    this.billId,
    this.budgetId,
    this.title,
    this.date,
    this.value: 0.0,
    this.balance: 0.0,
    this.note,
  });

  Transaction.fromJson(this.bookId, this.id, Map<String, dynamic> json)
    : billId    = parseString(mapValue(json, 'billId')),
      budgetId  = parseString(mapValue(json, 'budgetId')),
      title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      balance   = parseDouble(mapValue(json, 'balance')),
      note      = parseString(mapValue(json, 'note'));

  Transaction.fromSnapshot(String bookId, DataSnapshot snapshot)
    : this.fromJson(bookId, snapshot.key, snapshot.value);

  static Transaction of(String bookId) {
    return new Transaction(bookId);
  }

  Future<Transaction> get(String id) async {
    if (id == null) return null;
    final snap = await getNode(kNodeName, bookId).child(id).once();
    if (snap.value == null) return null;
    return new Transaction.fromSnapshot(bookId, snap);
  }

  Future<List<Transaction>> list(
      DateTime dateStart, DateTime dateEnd, openingBalance,
  ) async {
    final snap = await getNode(kNodeName, bookId).orderByChild('date')
        .startAt(dateStart.toIso8601String()).endAt(dateEnd.toIso8601String())
        .once();
    if (snap.value == null) return <Transaction>[];

    final items = <Transaction>[];
    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, value) {
      items.add(new Transaction.fromJson(bookId, key, value));
    });
    items.sort((a, b) => compareDate(b.date, a.date));

    fillBalance(items, openingBalance);

    return items;
  }

  static void fillBalance(List<Transaction> items, double openingBalance,
                          {bool reverse: true}) {
    if (items == null || items.length == 0) return;

    var balance = openingBalance;
    var i = 0;
    final len = items.length;

    while (i < len) {
      final idx = reverse ? len - i - 1 : i;
      final item = items[idx];
      balance += item.value;
      item.balance = balance;
      i++;
    }
  }

  Future<Null> save() async {
    final existing = id != null ? await get(id) : null;

    final node = getNode(kNodeName, bookId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;

    await _updateBudget(existing, this);
    await _updateBill(existing, this);
    await _updateBalance(existing, this);
  }

  Future<Null> removeById(String id) async {
    final item = await get(id);
    if (item == null) return;

    await getNode(kNodeName, bookId).child(id).remove();

    await _updateBudget(item, null);
    await _updateBill(item, null);
    await _updateBalance(item, null);
  }

  Future<Null> remove() async {
    if (id == null) return;
    final existing = await get(id);

    await getNode(kNodeName, bookId).child(id).remove();

    await _updateBudget(existing, null);
    await _updateBill(existing, null);
    await _updateBalance(existing, null);
  }

  Future<Null> _updateBudget(Transaction oldItem, Transaction newItem) async {
    if (oldItem != null && oldItem.budgetId != null) {
      final budget = await Budget.of(bookId).get(oldItem.budgetId);
      if (budget != null) {
        budget.spent -= -oldItem.value;
        await budget.save();
      }
    }
    if (newItem != null && newItem.budgetId != null) {
      final budget = await Budget.of(bookId).get(newItem.budgetId);
      if (budget != null) {
        budget.spent += -newItem.value;
        await budget.save();
      }
    }
  }

  Future<Null> _updateBill(Transaction oldItem, Transaction newItem) async {
    if (oldItem != null && oldItem.billId != null) {
      final bill = await Bill.of(bookId).get(oldItem.billId);
      if (bill != null) {
        bill.paidDate = oldItem.date;
        bill.paidValue -= oldItem.value * bill.transType;
        await bill.save();
        await bill.updateGroup();
      }
    }
    if (newItem != null && newItem.billId != null) {
      final bill = await Bill.of(bookId).get(newItem.billId);
      if (bill != null) {
        bill.paidDate = newItem.date;
        bill.paidValue += newItem.value * bill.transType;
        await bill.save();
        await bill.updateGroup();
      }
    }
  }

  Future<Null> _updateBalance(Transaction oldItem, Transaction newItem) async {
    if (oldItem != null) {
      final id = Balance.genId(oldItem.date.year, oldItem.date.month);
      final ref = getNode(Balance.kNodeName, bookId).child(id);
      final snap = await ref.once();
      final balance = parseDouble(snap.value);
      await ref.set(balance - oldItem.value);
    }
    if (newItem != null) {
      final id = Balance.genId(newItem.date.year, newItem.date.month);
      final ref = getNode(Balance.kNodeName, bookId).child(id);
      final snap = await ref.once();
      final balance = parseDouble(snap.value);
      await ref.set(balance + newItem.value);
    }
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

  final String bookId;

  String id;
  double value;

  Balance(this.bookId, {this.id, this.value : 0.0});

  Balance.fromSnapshot(this.bookId, DataSnapshot snapshot)
    : id = snapshot.key,
      value = parseDouble(snapshot.value);

  static Balance of(String bookId) {
    return new Balance(bookId);
  }

  int get year {
    if (id == null || id.length < 4) return 0;
    return parseInt(id.substring(0, 4)) ?? 0;
  }

  set year(int value) {
    final sYear = '$value';
    final sMonth = '$month';
    id = sYear.padLeft(4, '0') + sMonth.padLeft(2, '0');
  }

  int get month {
    if (id == null || id.length < 6) return 0;
    return parseInt(id.substring(4, 6)) ?? 0;
  }

  set month(int value) {
    final sYear = '$year';
    final sMonth = '$value';
    id = sYear.padLeft(4, '0') + sMonth.padLeft(2, '0');
  }

  Future<double> calculate(int year, int month) async {
    final httpClient = createHttpClient();
    final params = <String, dynamic>{
      'bookId' : bookId,
      'year'   : year,
      'month'  : month,
    };
    final uri = getUri(kFirebaseHost, kCalcOpeningBalancePath, params: params);
    final response = await httpClient.get(uri);
    Map<String, dynamic> json = JSON.decode(response.body);
    return parseDouble(mapValue(json, 'balance'));
  }

  Future<Balance> get(String id) async {
    if (id == null) return null;
    final snap = await getNode(kNodeName, bookId).child(id).once();
    if (snap.value == null) return null;
    return new Balance.fromSnapshot(bookId, snap);
  }

  Future<double> getValue(int year, int month) async {
    final id = genId(year, month);
    final node = getNode(kNodeName, bookId);
    final snap = await node.orderByKey().endAt(id).limitToLast(1).once();
    if (snap.value == null || !(snap.value is Map)) return 0.0;
    var value = 0.0;
    snap.value.forEach((key, item) {
      value = parseDouble(item);
      return;
    });
    return value;
  }

  Future<Null> setValue(int year, int month, double value) async {
    await getNode(kNodeName, bookId).child(genId(year, month)).set(value);
  }

  Future<Null> remove(String id) async {
    if (id == null) return;
    await getNode(kNodeName, bookId).child(id).remove();
  }

  static genId(int year, int month) {
    return new DateFormat(kPeriodFormat).format(new DateTime(year, month));
  }

}
