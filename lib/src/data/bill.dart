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

class BillGroup {
  static const kNodeName = 'billsGroup';

  String id;
  String title;
  int transType;
  DateTime startDate;
  DateTime endDate;
  double totalValue;
  int itemsCount;
  DateTime lastPaid;
  double paidValue;
  String note;

  BillGroup({
    this.id,
    this.title,
    this.transType,
    this.startDate,
    this.endDate,
    this.itemsCount: 0,
    this.totalValue: 0.0,
    this.lastPaid,
    this.paidValue: 0.0,
    this.note,
  });

  BillGroup.fromJson(this.id, Map<String, dynamic> json)
    : title      = parseString(mapValue(json, 'title')),
      transType  = parseInt(mapValue(json, 'transType')),
      startDate  = parseDate(mapValue(json, 'startDate')),
      endDate    = parseDate(mapValue(json, 'endDate')),
      totalValue = parseDouble(mapValue(json, 'totalValue')),
      lastPaid   = parseDate(mapValue(json, 'lastPaid')),
      paidValue  = parseDouble(mapValue(json, 'paidValue')),
      note       = parseString(mapValue(json, 'note'));

  BillGroup.fromSnapshot(DataSnapshot snapshot)
    : id         = snapshot.key,
      title      = parseString(mapValue(snapshot.value, 'title')),
      transType  = parseInt(mapValue(snapshot.value, 'transType')),
      startDate  = parseDate(mapValue(snapshot.value, 'startDate')),
      endDate    = parseDate(mapValue(snapshot.value, 'endDate')),
      totalValue = parseDouble(mapValue(snapshot.value, 'totalValue')),
      lastPaid   = parseDate(mapValue(snapshot.value, 'lastPaid')),
      paidValue  = parseDouble(mapValue(snapshot.value, 'paidValue')),
      note       = parseString(mapValue(snapshot.value, 'note'));

  static Future<BillGroup> get(String bookId, String id) async {
    if (id == null) return null;
    final snap = await getNode(bookId).child(id).once();
    if (snap.value == null) return null;
    return new BillGroup.fromSnapshot(snap);
  }

  static Future<List<BillGroup>> list(String bookId) async {
    final snap = await getNode(bookId).once();
    if (snap.value == null) return null;

    final items = <BillGroup>[];
    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) => items.add(new BillGroup.fromJson(key, json)));
    items.sort((a, b) => a.startDate?.compareTo(b.startDate) ?? 0);
    return items;
  }

  static Future<List<Bill>> getItems(String bookId, String groupId) async {
    final snap = await Bill.getNode(bookId).orderByChild('groupId').equalTo(groupId).once();
    if (snap.value == null) return null;

    final items = <Bill>[];
    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) => items.add(new Bill.fromJson(key, json)));
    items.sort((a, b) => a.date?.compareTo(b.date) ?? 0);
    return items;
  }

  Future<Null> save(String bookId) async {
    final node = getNode(bookId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;
  }

  Future<Null> saveItems(String bookId, List<Bill> items) async {
    await removeItems(bookId, exclude: items);

    final node = Bill.getNode(bookId);
    for (final item in items) {
      final snap = item.id != null ? node.child(item.id) : node.push();
      await snap.set(item.toJson());
      item.id = snap.key;
    }
  }

  static Future<Null> remove(String bookId, String id) async {
    final item = await get(bookId, id);
    if (item == null) return;
    await item.removeItems(bookId);

    final node = getNode(bookId);
    await node.child(id).remove();
  }

  Future<Null> removeItems(String bookId, {List<Bill> exclude}) async {
    final node = Bill.getNode(bookId);
    final existing = await node.orderByChild('groupId').equalTo(id).once();
    if (existing.value is Map) {
      existing.value.forEach((key, value) async {
        if (exclude == null || !_inItems(key, exclude)) {
          await node.child(key).remove();
        }
      });
    }
  }

  static bool _inItems(String key, List<Bill> items) {
    for (final item in items) {
      if (item.id == key) return true;
    }
    return false;
  }

  static DatabaseReference getNode(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson({showId: false}) {
    final json = <String, dynamic>{
      'id'         : id,
      'title'      : title,
      'transType'  : transType,
      'startDate'  : startDate?.toIso8601String(),
      'endDate'    : endDate?.toIso8601String(),
      'totalValue' : totalValue,
      'lastPaid'   : lastPaid?.toIso8601String(),
      'paidValue'  : paidValue,
      'note'       : note,
    };
    if (!showId) json.remove('id');
    return json;
  }
}

class Bill {
  static const kNodeName = 'bills';

  String id;
  String groupId;
  String title;
  DateTime date;
  double value;
  DateTime paidDate;
  double paidValue;
  String descr;

  Bill({
    this.id,
    this.groupId,
    this.title,
    this.date,
    this.value: 0.0,
    this.paidDate,
    this.paidValue: 0.0,
    this.descr,
  });

  Bill.fromJson(this.id, Map<String, dynamic> json)
    : groupId   = parseString(mapValue(json, 'groupId')),
      title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      paidDate  = parseDate(mapValue(json, 'paidDate')),
      paidValue = parseDouble(mapValue(json, 'paidValue')),
      descr     = parseString(mapValue(json, 'descr'));

  Bill.fromSnapshot(DataSnapshot snapshot)
    : id        = snapshot.key,
      groupId   = parseString(mapValue(snapshot.value, 'groupId')),
      title     = parseString(mapValue(snapshot.value, 'title')),
      date      = parseDate(mapValue(snapshot.value, 'date')),
      value     = parseDouble(mapValue(snapshot.value, 'value')),
      paidDate  = parseDate(mapValue(snapshot.value, 'paidDate')),
      paidValue = parseDouble(mapValue(snapshot.value, 'paidValue')),
      descr     = parseString(mapValue(snapshot.value, 'descr'));

  static Future<Bill> get(String bookId, String id) async {
    final snap = await getNode(bookId).child(id).once();
    if (snap.value == null) return null;
    return new Bill.fromSnapshot(snap);
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
      'groupId'   : groupId,
      'title'     : title,
      'date'      : date?.toIso8601String(),
      'value'     : value,
      'paidDate'  : paidDate?.toIso8601String(),
      'paidValue' : paidValue,
      'descr'     : descr,
    };
    if (!showId) json.remove('id');
    return json;
  }
}
