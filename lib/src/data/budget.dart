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

class Budget {
  static const kNodeName = 'budgets';

  String id;
  String title;
  DateTime date;
  double value;
  double spent;
  bool isExpire;
  String descr;

  Budget({
    this.id,
    this.title,
    this.date,
    this.value: 0.0,
    this.spent: 0.0,
    this.isExpire: false,
    this.descr,
  });

  Budget.fromJson(this.id, Map<String, dynamic> json)
    : title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      spent     = parseDouble(mapValue(json, 'spent')),
      isExpire  = parseBool(mapValue(json, 'isExpire')),
      descr     = parseString(mapValue(json, 'descr'));

  Budget.fromSnapshot(DataSnapshot snapshot)
    : id        = snapshot.key,
      title     = parseString(mapValue(snapshot.value, 'title')),
      date      = parseDate(mapValue(snapshot.value, 'date')),
      value     = parseDouble(mapValue(snapshot.value, 'value')),
      spent     = parseDouble(mapValue(snapshot.value, 'spent')),
      isExpire  = parseBool(mapValue(snapshot.value, 'isExpire', false)),
      descr     = parseString(mapValue(snapshot.value, 'descr'));

  static Future<Budget> get(String bookId, String id) async {
    if (id == null) return null;
    final snap = await getNode(bookId).child(id).once();
    if (snap.value == null) return null;
    return new Budget.fromSnapshot(snap);
  }

  static Future<List<Budget>> list(String bookId) async {
    final snap = await getNode(bookId).once();
    if (snap.value == null) return null;

    final items = <Budget>[];
    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) => items.add(new Budget.fromJson(key, json)));
    items.sort((a, b) => a.date?.compareTo(b.date) ?? 0);
    return items;
  }

  Future<List<Transaction>> getTransactions(String bookId) async {
    final ret = <Transaction>[];
    final node = Transaction.getNode(bookId);
    final snap = await node.orderByChild('budgetId').equalTo(id).once();
    if (snap.value == null) return ret;

    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) {
      ret.add(new Transaction.fromJson(key, json));
    });
    ret.sort((a, b) => a.date?.compareTo(b.date) ?? 0);

    return ret;
  }

  Future<Null> save(String bookId) async {
    final node = getNode(bookId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;
  }

  static Future<Null> remove(String bookId, String id) async {
    final node = getNode(bookId);
    await node.child(id).remove();
  }

  static DatabaseReference getNode(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson({showId: false}) {
    final json = <String, dynamic>{
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
