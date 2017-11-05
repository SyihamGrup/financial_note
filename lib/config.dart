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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPrefSignInMethod = 'signInMethod';
const kPrefSignInGoogle = 'signInGoogle';

const kPrefTheme = 'theme';
const kPrefThemeLight = 'light';
const kPrefThemeDark = 'dark';
const kPrefCurrencySymbol = 'currencySymbol';

const kPrefBookId = 'bookId';

class Config {
  Brightness _brightness;
  String _currencySymbol;

  Config({brightness, currencySymbol})
    : _brightness = brightness, _currencySymbol = currencySymbol;

  Config.fromPreferences(SharedPreferences prefs)
    : _brightness = prefs.getString(kPrefTheme) == kPrefThemeDark
                  ? Brightness.dark : Brightness.light,
    _currencySymbol = prefs.getString(kPrefCurrencySymbol) ?? '';

  static Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  Brightness get brightness => _brightness;

  Future<Null> setBrightness(Brightness value) async {
    _brightness = value;
    final prefs = await getSharedPreferences();
    final themeStr = value == Brightness.light ? kPrefThemeLight : kPrefThemeDark;
    prefs.setString(kPrefTheme, themeStr);
  }

  String get currencySymbol => _currencySymbol;

  Future<Null> setCurrencySymbol(String value) async {
    _currencySymbol = value;
    final prefs = await getSharedPreferences();
    prefs.setString(kPrefCurrencySymbol, value);
  }

  ThemeConfig getItemTheme(BuildContext context) {
    final theme = Theme.of(context);
    if (_brightness == Brightness.light) {
      return new ThemeConfig(
        appBarBackground: Colors.white,
        appBarTextTheme: theme.textTheme,
        appBarIconTheme: theme.iconTheme,
        appBarElevation: 1.0,
        formBackground: Colors.white,
      );
    } else {
      return new ThemeConfig(
        appBarBackground: Colors.grey[850],
        appBarTextTheme: theme.primaryTextTheme,
        appBarIconTheme: theme.primaryIconTheme,
        appBarElevation: 1.0,
        formBackground: null,
      );
    }
  }

  ThemeConfig getSettingTheme(BuildContext context) {
    final theme = Theme.of(context);
    return new ThemeConfig(
      appBarBackground: _brightness == Brightness.light ? Colors.blueGrey[700] : null,
      appBarTextTheme: theme.primaryTextTheme,
      appBarIconTheme: theme.primaryIconTheme,
      appBarElevation: 4.0,
    );
  }

  static ThemeData getTheme(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return new ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal[700],
          accentColor: Colors.orangeAccent[700],
        );
      case Brightness.dark:
        return new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent[700],
        );
    }
    return null;
  }
}

class ThemeConfig {
  Color appBarBackground;
  TextTheme appBarTextTheme;
  IconThemeData appBarIconTheme;
  double appBarElevation;
  Color formBackground;

  ThemeConfig({
    this.appBarBackground,
    this.appBarTextTheme,
    this.appBarIconTheme,
    this.appBarElevation,
    this.formBackground,
  });
}
