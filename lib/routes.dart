/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'dart:convert';

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/globals.dart' as globals;
import 'package:financial_note/page.dart';
import 'package:flutter/material.dart';

Widget getRoute(BuildContext context, RouteSettings settings,
                Config config, ValueChanged<Config> configUpdater) {
  final routes = getRouteParams(settings), routeName = routes[0], params = routes[1];

  switch (routeName) {
    // Sign In
    case SignInPage.kRouteName:
      return new SignInPage();

    // Settings
    case SettingsPage.kRouteName:
      return new SettingsPage(config, configUpdater);

    // Home page
    case HomePage.kRouteName:
      return new HomePage(bookId: globals.currentBook.id);

    // Transaction page
    case TransactionPage.kRouteName:
      return new TransactionPage(bookId: globals.currentBook.id);

    // Budget page
    case BudgetPage.kRouteName:
      final data = params is Map && params.containsKey('data')
              ? new Budget.fromJson(params['data']) : null;
      return new BudgetPage(bookId: globals.currentBook.id, data: data);

    // Splash
    case '/':
      return new SplashPage();
  }
  return null;
}

/// Push named navigator dengan params.
String routeWithParams(String routeName, Map<String, dynamic> params) {
  if (params != null) routeName += '?' + JSON.encode(params);
  return routeName;
}

/// Get route name dan parameter dari route RouteSettings
/// return array Index 0 -> route name, Index 1 -> params
List<dynamic> getRouteParams(RouteSettings settings) {
  if (settings.name == null) return [null, null];

  final routes = settings.name.split('?');
  return [
    routes[0],
    routes.length > 1 ? JSON.decode(routes[1]) : null,
  ];
}

