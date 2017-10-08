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
    : title      = json != null && json.containsKey('title')      ? json['title']                    : null,
      dueDate    = json != null && json.containsKey('dueDate')    ? DateTime.parse(json['dueDate'])  : null,
      totalValue = json != null && json.containsKey('totalValue') ? parseDouble(json['totalValue'])  : 0.0,
      lastPaid   = json != null && json.containsKey('lastPaid')   ? DateTime.parse(json['lastPaid']) : null,
      paidValue  = json != null && json.containsKey('paidValue')  ? parseDouble(json['paidValue'])   : 0.0,
      note       = json != null && json.containsKey('note')       ? json['note']                     : null;

  static DatabaseReference ref(String bookId) {
    return db.child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson() {
    final formatter = new DateFormat('yyyy-MM-dd');
    return <String, dynamic>{
      'id'         : id,
      'title'      : title,
      'dueDate'    : formatter.format(dueDate),
      'totalValue' : totalValue,
      'lastPaid'   : formatter.format(lastPaid),
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
    : groupId   = json != null && json.containsKey('groupId')   ? json['groupId']                  : null,
      title     = json != null && json.containsKey('title')     ? json['title']                    : null,
      date      = json != null && json.containsKey('date')      ? DateTime.parse(json['date'])     : null,
      value     = json != null && json.containsKey('value')     ? parseDouble(json['value'])       : 0.0,
      paidDate  = json != null && json.containsKey('paidDate')  ? DateTime.parse(json['paidDate']) : null,
      paidValue = json != null && json.containsKey('paidValue') ? parseDouble(json['paidValue'])   : 0.0,
      note      = json != null && json.containsKey('note')      ? json['note']                     : null;

  static DatabaseReference ref(String bookId) {
    return db.child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson() {
    final formatter = new DateFormat('yyyy-MM-dd');
    return <String, dynamic>{
      'id'        : id,
      'groupId'   : groupId,
      'title'     : title,
      'date'      : formatter.format(date),
      'value'     : value,
      'paidDate'  : formatter.format(paidDate),
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
