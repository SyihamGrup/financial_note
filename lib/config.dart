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

enum ThemeName { light, dark }

class Config {
  final ThemeName themeName;
  final String currencySymbol;

  const Config({this.themeName, this.currencySymbol});

  Config copyWith({ThemeName themeName, String currencySymbol}) {
    return new Config(
      themeName: themeName ?? this.themeName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

ThemeData getTheme(ThemeName themeName) {
  switch (themeName) {
    case ThemeName.light:
      return new ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        primaryColor: Colors.teal[700],
        accentColor: Colors.orangeAccent[700],
      );
    case ThemeName.dark:
      return new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        accentColor: Colors.tealAccent[700],
      );
  }
  return null;
}
