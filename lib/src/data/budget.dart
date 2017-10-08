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

  Budget.fromSnapshot(DataSnapshot snapshot)
    : id = snapshot.value('id'),
      title = snapshot.value('title'),
      date = DateTime.parse(snapshot.value('date')),
      value = snapshot.value('value'),
      usedValue = snapshot.value('usedValue') ?? 0.0,
      isExpire = snapshot.value('isExpire') ?? false;

  Map<String, dynamic> toJson({showId: false}) {
    var json = <String, dynamic>{
      'id'        : id,
      'title'     : title,
      'date'      : date,
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
