/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:flutter/material.dart';

const kPrefSignInMethod = 'signInMethod';
const kPrefSignInGoogle = 'signInGoogle';

const kPrefTheme = 'theme';
const kPrefThemeLight = 'light';
const kPrefThemeDark = 'dark';
const kPrefCurrencySymbol = 'currencySymbol';

const kPrefBookId = 'bookId';

class Config {
  final Brightness brightness;
  final String currencySymbol;

  const Config({this.brightness, this.currencySymbol});

  Config copyWith({Brightness brightness, String currencySymbol}) {
    return new Config(
      brightness: brightness ?? this.brightness,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

ThemeData getTheme(Brightness brightness) {
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
