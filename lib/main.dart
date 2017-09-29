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
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kTitle = 'Financial Note';

Future<Null> main() async {
  final prefs = await SharedPreferences.getInstance();
  final config = new Config.fromPrefs(prefs);
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

  Route<Null> _getRoute(RouteSettings settings) {
    return new MaterialPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) {
        switch (settings.name) {
          case SignInPage.kRouteName:
            return new SignInPage();
          case SettingsPage.kRouteName:
            return new SettingsPage(_config, _configUpdater);
          case HomePage.kRouteName:
            return new HomePage();
          case TransactionPage.kRouteName:
            return new TransactionPage();
          default:
            return new SplashPage();
        }
      }
    );
  }

  void _configUpdater(Config value) {
    setState(() => _config = value);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: kTitle,
      theme: _config.themeData,
      localizationsDelegates: <_LocalizationsDelegate>[
        new _LocalizationsDelegate()
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('id', 'ID'),
      ],
      onGenerateRoute: _getRoute,
    );
  }
}

class _LocalizationsDelegate extends LocalizationsDelegate<Lang> {
  @override
  Future<Lang> load(Locale locale) => Lang.load(locale);

  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}
