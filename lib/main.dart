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

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kTitle = 'Financial Note';

Future<Null> main() async {
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10 * 1000 * 1000);

  runApp(new MainApp(await _initConfig()));
}

Future<Config> _initConfig() async {
  final prefs = await SharedPreferences.getInstance();
  return new Config(
    brightness     : prefs.getString(kPrefTheme) == kPrefThemeDark
                   ? Brightness.dark : Brightness.light,
    currencySymbol : prefs.getString(kPrefCurrencySymbol) ?? 'Rp'
  );
}

class MainApp extends StatefulWidget {
  final Config _config;

  const MainApp(this._config);

  @override
  _MainAppState createState() => new _MainAppState(_config);
}

class _MainAppState extends State<MainApp> {
  Config _config;

  _MainAppState(this._config);

  Widget _getRoute(
    BuildContext context,
    RouteSettings settings,
    Config config,
    ValueChanged<Config> configUpdater
  ) {
    final route = getRouteParams(settings);
    final id = mapValue<String>(route.params, 'id');

    switch (route.name) {
      // Sign In
      case SignInPage.kRouteName:
        return new SignInPage();

      // Settings
      case SettingsPage.kRouteName:
        return new SettingsPage(config: config, updater: configUpdater);

      // Balance List
      case BalanceListPage.kRouteName:
        return new BalanceListPage(config: config, bookId: currentBook?.id);

      // Balance
      case BalancePage.kRouteName:
        return new BalancePage(config: config, bookId: currentBook?.id, id: id);

      // Home page
      case HomePage.kRouteName:
        return new HomePage(bookId: currentBook?.id, config: config);

      // Transaction page
      case TransactionPage.kRouteName:
        return new TransactionPage(config: config, bookId: currentBook?.id, id: id);

      // Bill page
      case BillPage.kRouteName:
        return new BillPage(config: config, bookId: currentBook?.id, groupId: id);

      // View bill page
      case BillViewPage.kRouteName:
        return new BillViewPage(config: config, bookId: currentBook?.id, id: id);

      // Budget page
      case BudgetPage.kRouteName:
        return new BudgetPage(config: config, bookId: currentBook?.id, id: id);

      // View budget page
      case BudgetViewPage.kRouteName:
        return new BudgetViewPage(config: config, bookId: currentBook?.id, id: id);

      // Note page
      case NotePage.kRouteName:
        return new NotePage(config: config, bookId: currentBook?.id, id: id);

      // Splash
      case '/':
        return new SplashPage();
    }
    return null;
  }

  void _configUpdater(Config config) {
    setState(() => _config = config);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: kTitle,
      theme: Config.getTheme(_config.brightness),
      localizationsDelegates: <_LocalizationsDelegate>[
        new _LocalizationsDelegate()
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('id', 'ID'),
      ],
      onGenerateRoute: (settings) {
        return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) {
            return _getRoute(context, settings, _config, _configUpdater);
          },
        );
      },
    );
  }
}

class _LocalizationsDelegate extends LocalizationsDelegate<Lang> {
  @override
  Future<Lang> load(Locale locale) => Lang.load(locale);

  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}
