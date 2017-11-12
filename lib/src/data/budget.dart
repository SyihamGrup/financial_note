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

class Budget implements Data {
  static const kNodeName = 'budgets';

  final String bookId;

  String id;
  String title;
  DateTime date;
  double value;
  double spent;
  bool isExpire;
  String descr;

  Budget(this.bookId, {
    this.id,
    this.title,
    this.date,
    this.value: 0.0,
    this.spent: 0.0,
    this.isExpire: false,
    this.descr,
  });

  Budget.fromJson(this.bookId, this.id, Map<String, dynamic> json)
    : title     = parseString(valueOf(json, 'title')),
      date      = parseDate(valueOf(json, 'date')),
      value     = parseDouble(valueOf(json, 'value')),
      spent     = parseDouble(valueOf(json, 'spent')),
      isExpire  = parseBool(valueOf(json, 'isExpire')),
      descr     = parseString(valueOf(json, 'descr'));

  Budget.fromSnapshot(String bookId, DataSnapshot snapshot)
    : this.fromJson(bookId, snapshot.key, snapshot.value);

  static Budget of(String bookId) {
    return new Budget(bookId);
  }

  Future<Budget> get(String id) async {
    if (id == null) return null;
    final snap = await getNode(kNodeName, bookId).child(id).once();
    if (snap.value == null) return null;
    return new Budget.fromSnapshot(bookId, snap);
  }

  Future<List<Budget>> list() async {
    final items = <Budget>[];

    final snap = await getNode(kNodeName, bookId).once();
    if (snap.value == null) return items;

    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) {
      items.add(new Budget.fromJson(bookId, key, json));
    });
    items.sort((a, b) => compareDate(b.date, a.date));
    return items;
  }

  Future<List<Transaction>> getTransactions() async {
    final items = <Transaction>[];

    final node = getNode(Transaction.kNodeName, bookId);
    final snap = await node.orderByChild('budgetId').equalTo(id).once();
    if (snap.value == null) return items;

    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) {
      items.add(new Transaction.fromJson(bookId, key, json));
    });
    items.sort((a, b) => compareDate(b.date, a.date));

    return items;
  }

  Future<Null> save() async {
    final node = getNode(kNodeName, bookId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;
  }

  Future<Null> removeById(String id) async {
    if (id == null) return;
    await getNode(kNodeName, bookId).child(id).remove();
  }

  Future<Null> remove() async {
    await removeById(id);
  }

  Map<String, dynamic> toJson({showId: false}) {
    final json = {
      'id'        : id,
      'title'     : title,
      'date'      : date?.toIso8601String(),
      'value'     : value,
      'spent'     : spent,
      'isExpire'  : isExpire,
      'descr'     : descr,
    };
    if (!showId) json.remove('id');
    return json;
  }
}
