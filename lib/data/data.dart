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

import 'package:financial_note/data/config.dart';
import 'package:financial_note/i18n/strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'book.dart';
part 'transaction.dart';

const kFirebaseUriScheme = 'https';
const kFirebaseHost = 'us-central1-financialnote-d6d95.cloudfunctions.net';

const kOpeningBalancePath = '/getOpeningBalance';

final _db = FirebaseDatabase.instance.reference();

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

/// Parse double from dynamic variable.
double parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  return 0.0;
}

/// Parse integer from dynamic variable.
int parseInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  return 0;
}
