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
import 'dart:convert';

import 'package:financial_note/data.dart';
import 'package:financial_note/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class Balance {
  static const kNodeName = 'balances';

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  static Future<double> get(String bookId, int year, int month) async {
    final snap = await ref(bookId).child("$year$month").once();
    return parseDouble(snap.value);
  }

  static Future<Null> calculate(String bookId, int year, int month) async {
    final httpClient = createHttpClient();

    final params = <String, dynamic>{
      'bookId' : bookId,
      'year'   : year,
      'month'  : month,
    };
    final response = await httpClient.get(firebaseUri(kCalcOpeningBalancePath, params));

    Map<String, dynamic> json = JSON.decode(response.body);
    return json.containsKey('balance') ? parseDouble(json['balance']) : 0.0;
  }

}
