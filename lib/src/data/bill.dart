/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/utils.dart';
import 'package:firebase_database/firebase_database.dart';

class BillGroup {
  static const kNodeName = 'bills';

  String id;
  String title;
  DateTime dueDate;
  double totalValue;
  DateTime lastPaid;
  double paidValue;
  String note;

  BillGroup({
    this.id,
    this.title,
    this.dueDate,
    this.totalValue: 0.0,
    this.lastPaid,
    this.paidValue: 0.0,
    this.note,
  });

  BillGroup.fromJson(Map<String, dynamic> json)
    : id         = parseString(mapValue(json, 'id')),
      title      = parseString(mapValue(json, 'title')),
      dueDate    = parseDate(mapValue(json, 'dueDate')),
      totalValue = parseDouble(mapValue(json, 'totalValue')),
      lastPaid   = parseDate(mapValue(json, 'lastPaid')),
      paidValue  = parseDouble(mapValue(json, 'paidValue')),
      note       = parseString(mapValue(json, 'note'));

  BillGroup.fromSnapshot(DataSnapshot snapshot)
    : id         = snapshot.key,
      title      = parseString(mapValue(snapshot.value, 'title')),
      dueDate    = parseDate(mapValue(snapshot.value, 'dueDate')),
      totalValue = parseDouble(mapValue(snapshot.value, 'totalValue')),
      lastPaid   = parseDate(mapValue(snapshot.value, 'lastPaid')),
      paidValue  = parseDouble(mapValue(snapshot.value, 'paidValue')),
      note       = parseString(mapValue(snapshot.value, 'note'));

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id'         : id,
      'title'      : title,
      'dueDate'    : dueDate?.toIso8601String(),
      'totalValue' : totalValue,
      'lastPaid'   : lastPaid?.toIso8601String(),
      'paidValue'  : paidValue,
      'note'       : note,
    };
  }

  BillGroup copyWith({
    String id,
    String title,
    DateTime dueDate,
    double totalValue,
    DateTime lastPaid,
    double paidValue,
    String note,
  }) {
    return new BillGroup(
      id         : id         ?? this.id,
      title      : title      ?? this.title,
      dueDate    : dueDate    ?? this.dueDate,
      totalValue : totalValue ?? this.totalValue,
      lastPaid   : lastPaid   ?? this.lastPaid,
      paidValue  : paidValue  ?? this.paidValue,
      note       : note       ?? this.note,
    );
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
  String note;
  String descr;

  Bill({
    this.id,
    this.groupId,
    this.title,
    this.date,
    this.value,
    this.paidDate,
    this.paidValue,
    this.note,
    this.descr,
  });

  Bill.fromJson(Map<String, dynamic> json)
    : id        = parseString(mapValue(json, 'id')),
      groupId   = parseString(mapValue(json, 'groupId')),
      title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      paidDate  = parseDate(mapValue(json, 'paidDate')),
      paidValue = parseDouble(mapValue(json, 'paidValue')),
      note      = parseString(mapValue(json, 'note')),
      descr     = parseString(mapValue(json, 'descr'));

  Bill.fromSnapshot(DataSnapshot snapshot)
    : id        = snapshot.key,
      groupId   = parseString(mapValue(snapshot.value, 'groupId')),
      title     = parseString(mapValue(snapshot.value, 'title')),
      date      = parseDate(mapValue(snapshot.value, 'date')),
      value     = parseDouble(mapValue(snapshot.value, 'value')),
      paidDate  = parseDate(mapValue(snapshot.value, 'paidDate')),
      paidValue = parseDouble(mapValue(snapshot.value, 'paidValue')),
      note      = parseString(mapValue(snapshot.value, 'note')),
      descr     = parseString(mapValue(snapshot.value, 'descr'));

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id'        : id,
      'groupId'   : groupId,
      'title'     : title,
      'date'      : date?.toIso8601String(),
      'value'     : value,
      'paidDate'  : paidDate?.toIso8601String(),
      'paidValue' : paidValue,
      'note'      : note,
      'descr'     : descr,
    };
  }

  Bill copyWith({
    String id,
    String groupId,
    String title,
    DateTime date,
    double value,
    DateTime paidDate,
    double paidValue,
    String note,
    String descr,
  }) {
    return new Bill(
      id        : id        ?? this.id,
      groupId   : groupId   ?? this.groupId,
      title     : title     ?? this.title,
      date      : date      ?? this.date,
      value     : value     ?? this.value,
      paidDate  : paidDate  ?? this.paidDate,
      paidValue : paidValue ?? this.paidValue,
      note      : note      ?? this.note,
      descr     : descr     ?? this.descr,
    );
  }

}
