// Copyright (c) 2017. All rights reserved.
//
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//
// Written by:
//   - Adi Sayoga <adisayoga@gmail.com>

import 'dart:async';
import 'dart:convert';

import 'package:financial_note/auth/auth.dart';
import 'package:financial_note/data/config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _ref = FirebaseDatabase.instance.reference();

class TransactionGroup {
  static const nodeName = 'transactions_groups';

  String id;
  DateTime dueDate;
  DateTime lastPaid;
  double totalValue;
  double paidValue;

  final transactions = <String, bool>{};

  TransactionGroup({
    this.id,
    this.dueDate,
    this.lastPaid,
    this.totalValue,
    this.paidValue
  });

//  TransactionGroup.fromJson(Map json)
//      : id = json['id'],
//        dueDate = json['dueDate'],
//        lastPaid = json['lastPaid'],
//        totalValue = json['totalValue'],
//        paidValue = json['paidValue'];
//
//  Map<String, dynamic> toJson() {
//    return <String, dynamic>{
//      'id': id,
//      'dueDate': dueDate,
//      'lastPaid': lastPaid,
//      'totalValue': totalValue,
//      'paidValue': paidValue
//    };
//  }
}

class Transaction {
  static const nodeName = 'transactions';

  String userId;

  String id;
  String groupId;
  String budgetId;
  String period;
  DateTime dueDate;
  DateTime paidDate;
  double value;
  double paidValue;
  String note;

  Transaction({
    @required this.userId,

    this.id,
    this.groupId,
    this.budgetId,
    this.period,
    this.dueDate,
    this.paidDate,
    this.value,
    this.paidValue,
    this.note,
  });

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        groupId = json['groupId'],
        budgetId = json['budgetId'],
        period = json['period'],
        dueDate = json['dueDate'],
        paidDate = json['paidDate'],
        value = json['value'],
        paidValue = json['paidValue'],
        note = json['note'];

  static Future<List<Transaction>> list(String userId, DateTime dateStart, DateTime dateEnd) async {
    var formatter = new DateFormat('yyyy-MM-dd');
    var ret = new List<Transaction>();

    var openingBalance = await getOpeningBalance(dateEnd);
    ret.add(new Transaction(
      userId: userId,
      paidDate: dateStart,
      paidValue: openingBalance
    ));

    var snap = await _ref.child(nodeName)
        .orderByChild('paidDate')
        .startAt(formatter.format(dateStart), key: 'paidDate')
        .endAt(formatter.format(dateEnd), key: 'paidDate')
        .once();

    var items = JSON.decode(snap.value);
    items.foEach((item, key) {
      ret.add(new Transaction(
        userId: userId,
        id: key,
        groupId: item['groupId'],
        budgetId: item['budgetId'],
        period: item['period'],
        dueDate: item['dueDate'],
        paidDate: item['paidDate'],
        value: item['value'],
        paidValue: item['paidValue'],
        note: item['note'],
      ));
    });

    return ret;
  }

  static StreamSubscription<Event> listen(Function cb) {
    return _ref.child(nodeName).onValue.listen(cb);
  }

  static Future<double> getOpeningBalance(DateTime dateEnd) async {
    var httpClient = createHttpClient();
    var response = await httpClient.get(new Uri(
      scheme: firebaseUriScheme,
      host: firebaseHost,
      path: openingBalancePath,
      queryParameters: <String, String>{
        "uid": googleSignIn.currentUser?.id,
        "date": new DateFormat('yyyy-MM-dd').format(dateEnd),
      }
    ));
    var json = JSON.decode(response.body);
    return json.containsKey('balance') ? json['balance'] : 0;
  }

  Future<Null> add(Transaction v) async {

    return null;
  }
}
