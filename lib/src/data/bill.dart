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
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class BillGroup {
  static const kNodeName = 'bills';

  final String id;
  final String title;
  final DateTime dueDate;
  final double totalValue;
  final DateTime lastPaid;
  final double paidValue;
  final String note;

  const BillGroup({
    this.id,
    @required this.title,
    @required this.dueDate,
    this.totalValue: 0.0,
    this.lastPaid,
    this.paidValue: 0.0,
    this.note,
  });

  BillGroup.fromJson(this.id, Map<String, dynamic> json)
    : title      = parseString(mapValue(json, 'title')),
      dueDate    = parseDate(mapValue(json, 'dueDate')),
      totalValue = parseDouble(mapValue(json, 'totalValue')),
      lastPaid   = parseDate(mapValue(json, 'lastPaid')),
      paidValue  = parseDouble(mapValue(json, 'paidValue')),
      note       = parseString(mapValue(json, 'note'));

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

  final String id;
  final String groupId;
  final String title;
  final DateTime date;
  final double value;
  final DateTime paidDate;
  final double paidValue;
  final String note;

  const Bill({
    this.id,
    this.groupId,
    @required this.title,
    @required this.date,
    @required this.value,
    this.paidDate,
    this.paidValue,
    this.note,
  });

  Bill.fromJson(this.id, Map<String, dynamic> json)
    : groupId   = parseString(mapValue(json, 'groupId')),
      title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      paidDate  = parseDate(mapValue(json, 'paidDate')),
      paidValue = parseDouble(mapValue(json, 'paidValue')),
      note      = parseString(mapValue(json, 'note'));

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson() {
    final formatter = new DateFormat('yyyy-MM-dd');
    return <String, dynamic>{
      'id'        : id,
      'groupId'   : groupId,
      'title'     : title,
      'date'      : date?.toIso8601String(),
      'value'     : value,
      'paidDate'  : paidDate?.toIso8601String(),
      'paidValue' : paidValue,
      'note'      : note,
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
    );
  }

}
