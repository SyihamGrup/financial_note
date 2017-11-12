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

class BillGroup implements Data {
  static const kNodeName = 'billsGroup';

  final String bookId;

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

  BillGroup(this.bookId, {
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

  BillGroup.fromJson(this.bookId, this.id, Map<String, dynamic> json)
    : title      = parseString(valueOf(json, 'title')),
      transType  = parseInt(valueOf(json, 'transType')),
      startDate  = parseDate(valueOf(json, 'startDate')),
      endDate    = parseDate(valueOf(json, 'endDate')),
      totalValue = parseDouble(valueOf(json, 'totalValue')),
      lastPaid   = parseDate(valueOf(json, 'lastPaid')),
      paidValue  = parseDouble(valueOf(json, 'paidValue')),
      note       = parseString(valueOf(json, 'note'));

  BillGroup.fromSnapshot(String bookId, DataSnapshot snapshot)
    : this.fromJson(bookId, snapshot.key, snapshot.value);

  static BillGroup of(String bookId) {
    return new BillGroup(bookId);
  }

  Future<BillGroup> get(String id) async {
    if (id == null) return null;
    final snap = await getNode(kNodeName, bookId).child(id).once();
    if (snap.value == null) return null;
    return new BillGroup.fromSnapshot(bookId, snap);
  }

  Future<List<BillGroup>> list() async {
    final items = <BillGroup>[];

    final snap = await getNode(kNodeName, bookId).once();
    if (snap.value == null) return items;

    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) {
      items.add(new BillGroup.fromJson(bookId, key, json));
    });
    items.sort((a, b) => compareDate(b.startDate, a.startDate));
    return items;
  }

  Future<List<Bill>> getItems(String groupId) async {
    final items = <Bill>[];

    if (groupId == null) return items;
    final node = getNode(Bill.kNodeName, bookId);
    final snap = await node.orderByChild('groupId').equalTo(groupId).once();
    if (snap.value == null) return items;

    final Map<String, Map<String, dynamic>> data = snap.value;
    data.forEach((key, json) {
      items.add(new Bill.fromJson(bookId, key, json));
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

  Future<Null> saveItems(List<Bill> items) async {
    await removeItems(exclude: items);

    final node = getNode(Bill.kNodeName, bookId);
    for (final item in items) {
      item.groupId = id;
      final snap = item.id != null ? node.child(item.id) : node.push();
      await snap.set(item.toJson());
      item.id = snap.key;
    }
  }

  Future<Null> removeById(String id) async {
    final item = await get(id);
    if (item == null) return;
    await item.remove();
  }

  Future<Null> remove() async {
    if (id == null) return;
    await removeItems();
    await getNode(kNodeName, bookId).child(id).remove();
  }

  Future<Null> removeItems({List<Bill> exclude}) async {
    final node = getNode(Bill.kNodeName, bookId);
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

  Map<String, dynamic> toJson({showId: false}) {
    final json = {
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

class Bill implements Data {
  static const kNodeName = 'bills';

  final String bookId;

  String id;
  String groupId;
  String title;
  int transType;
  DateTime date;
  double value;
  DateTime paidDate;
  double paidValue;
  String descr;

  Bill(this.bookId, {
    this.id,
    this.groupId,
    this.title,
    this.date,
    this.value: 0.0,
    this.paidDate,
    this.paidValue: 0.0,
    this.descr,
  });

  Bill.fromJson(this.bookId, this.id, Map<String, dynamic> json)
    : groupId   = parseString(valueOf(json, 'groupId')),
      title     = parseString(valueOf(json, 'title')),
      transType = parseInt(valueOf(json, 'transType')),
      date      = parseDate(valueOf(json, 'date')),
      value     = parseDouble(valueOf(json, 'value')),
      paidDate  = parseDate(valueOf(json, 'paidDate')),
      paidValue = parseDouble(valueOf(json, 'paidValue')),
      descr     = parseString(valueOf(json, 'descr'));

  Bill.fromSnapshot(String bookId, DataSnapshot snapshot)
    : this.fromJson(bookId, snapshot.key, snapshot.value);

  static Bill of(String bookId) {
    return new Bill(bookId);
  }

  Future<Bill> get(String id) async {
    if (id == null) return null;
    final snap = await getNode(kNodeName, bookId).child(id).once();
    if (snap.value == null) return null;
    return new Bill.fromSnapshot(bookId, snap);
  }

  Future<Null> updateGroup() async {
    final group = await BillGroup.of(bookId).get(groupId);
    if (group == null) return;

    group.startDate = null;
    group.endDate = null;
    group.itemsCount = 0;
    group.totalValue = 0.0;
    group.lastPaid = null;
    group.paidValue = 0.0;

    final items = await BillGroup.of(bookId).getItems(group.id);
    if (items != null || items.length > 0) {
      var i = 0;
      group.itemsCount = items.length;
      for (final item in items) {
        // start date adalah last item, karena sort descending
        if (i == group.itemsCount) group.startDate = item.date;
        if (i == 0) group.endDate = item.date;
        group.totalValue += item.value;
        if (item.paidDate != null) {
          group.paidValue += item.paidValue;
          if (group.lastPaid == null) group.lastPaid = item.paidDate;
        }
        i++;
      }
    }

    group.save();
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
      'groupId'   : groupId,
      'title'     : title,
      'transType' : transType,
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
