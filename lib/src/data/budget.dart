/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of data;

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
    : id        = json != null && json.containsKey('id')        ? json['id']                   : null,
      title     = json != null && json.containsKey('title')     ? json['title']                : null,
      date      = json != null && json.containsKey('date')      ? DateTime.parse(json['date']) : null,
      value     = json != null && json.containsKey('value')     ? json['value']                : null,
      usedValue = json != null && json.containsKey('usedValue') ? json['usedValue']            : null,
      isExpire  = json != null && json.containsKey('isExpire')  ? json['isExpire']             : null;

  Budget.fromSnapshot(DataSnapshot snapshot)
    : id = snapshot.key,
      title = mapValue(snapshot.value, 'title'),
      date = DateTime.parse(mapValue(snapshot.value, 'date')),
      value = parseDouble(mapValue(snapshot.value, 'value')),
      usedValue = parseDouble(mapValue(snapshot.value, 'usedValue')),
      isExpire = mapValue(snapshot.value, 'isExpire', def: false);

  Map<String, dynamic> toJson({showId: true}) {
    var json = <String, dynamic>{
      'id'        : id,
      'title'     : title,
      'date'      : date.toIso8601String(),
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
