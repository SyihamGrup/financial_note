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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kTitle = 'Financial Note';

Future<Null> main() async {
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString(kPrefTheme) == kPrefThemeDark ? ThemeName.dark : ThemeName.light;
  final config = new Config(theme: theme);

  runApp(new MainApp(config));
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

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10 * 1000 * 1000);
  }

  Widget _getRoute(BuildContext context, RouteSettings settings,
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
        return new HomePage(bookId: currentBook?.id);

      // Transaction page
      case TransactionPage.kRouteName:
        return new TransactionPage(bookId: currentBook?.id);

      // Budget page
      case BudgetPage.kRouteName:
        final data = params is Map && params.containsKey('data')
                ? new Budget.fromJson(params['data']) : null;
        return new BudgetPage(bookId: currentBook?.id, data: data);

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
      theme: getTheme(_config.theme),
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
