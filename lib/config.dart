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

const kPrefBookId = 'bookId';

enum ThemeName { light, dark }

enum SignInMethod { google }

class Config {
  final ThemeName theme;

  const Config({this.theme});

  Config copyWith({ThemeName theme}) {
    return new Config(
      theme: theme ?? this.theme,
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
