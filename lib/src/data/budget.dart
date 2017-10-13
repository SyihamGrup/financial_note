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

class Budget {
  static const kNodeName = 'budgets';

  String id;
  String title;
  DateTime date;
  double value;
  double usedValue;
  bool isExpire;

  Budget({
    this.id,
    @required this.title,
    @required this.date,
    @required this.value,
    this.usedValue: 0.0,
    this.isExpire: false,
  });

  Budget.fromJson(Map<String, dynamic> json)
    : id        = parseString(mapValue(json, 'id')),
      title     = parseString(mapValue(json, 'title')),
      date      = parseDate(mapValue(json, 'date')),
      value     = parseDouble(mapValue(json, 'value')),
      usedValue = parseDouble(mapValue(json, 'usedValue')),
      isExpire  = parseBool(mapValue(json, 'isExpire'));

  Budget.fromSnapshot(DataSnapshot snapshot)
    : id        = snapshot.key,
      title     = parseString(mapValue(snapshot.value, 'title')),
      date      = parseDate(mapValue(snapshot.value, 'date')),
      value     = parseDouble(mapValue(snapshot.value, 'value')),
      usedValue = parseDouble(mapValue(snapshot.value, 'usedValue')),
      isExpire  = parseBool(mapValue(snapshot.value, 'isExpire', def: false));

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson({showId: true}) {
    final json = <String, dynamic>{
      'id'        : id,
      'title'     : title,
      'date'      : date?.toIso8601String(),
      'value'     : value,
      'usedValue' : usedValue,
      'isExpire'  : isExpire,
    };
    if (!showId) json.remove('id');
    return json;
  }

  Budget copyWith({
    String id,
    String title,
    DateTime date,
    double value,
    double usedValue,
    bool isExpire,
  }) {
    return new Budget(
      id        : id        ?? this.id,
      title     : title     ?? this.title,
      date      : date      ?? this.date,
      value     : value     ?? this.value,
      usedValue : usedValue ?? this.usedValue,
      isExpire  : isExpire  ?? this.isExpire,
    );
  }

}
