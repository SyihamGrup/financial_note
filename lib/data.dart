/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library data;

import 'dart:async';
import 'dart:convert';

import 'package:financial_note/config.dart';
import 'package:financial_note/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'src/data/balance.dart';
part 'src/data/bill.dart';
part 'src/data/book.dart';
part 'src/data/budget.dart';
part 'src/data/transaction.dart';

const kFirebaseUriScheme = 'https';
const kFirebaseHost = 'us-central1-financialnote-d6d95.cloudfunctions.net';

const kOpeningBalancePath = '/getOpeningBalance';
const kCalcOpeningBalancePath = '/calcOpeningBalance';

final db = FirebaseDatabase.instance.reference();

/// Get firebase uri
Uri firebaseUri(String path, Map<String, dynamic> params, {
  String scheme: kFirebaseUriScheme,
  String host: kFirebaseHost,
}) {
  return new Uri(
    scheme: scheme,
    host:   host,
    path:   path,
    queryParameters: params,
  );
}
