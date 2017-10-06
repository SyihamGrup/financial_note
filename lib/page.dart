
/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page;

import 'dart:async';
import 'dart:convert';

import 'package:financial_note/auth.dart';
import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'src/page/home_page.dart';
part 'src/page/home_page_bill.dart';
part 'src/page/home_page_budget.dart';
part 'src/page/home_page_transaction.dart';
part 'src/page/page.dart';
part 'src/page/settings_page.dart';
part 'src/page/sign_in_page.dart';
part 'src/page/splash_page.dart';
part 'src/page/transaction_page.dart';

/// Push named navigator dengan params.
String routeWithParams(String routeName, Map<String, dynamic> params) {
  if (params != null) routeName += '?' + JSON.encode(params);
  return routeName;
}

/// Get route name dan parameter dari route RouteSettings
/// return array Index 0 -> route name, Index 1 -> params
List<dynamic> getRoute(RouteSettings settings) {
  if (settings.name == null) return [null, null];

  var routes = settings.name.split('?');
  return [
    routes[0],
    routes.length > 1 ? JSON.decode(routes[1]) : null,
  ];
}
