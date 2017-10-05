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
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePick { light, dark }

enum SignInMethod { google }

class Config {
  static const kCurrentUserId = 'currentUserId';
  static const kTheme = 'theme';
  static const kThemeLight = 'light';
  static const kThemeDark = 'dark';
  static const kSignInMethod = 'signInMethod';
  static const kSignInGoogle = 'signInGoogle';
  static const kBookId = 'bookId';

  final ThemePick theme;
  final SignInMethod signInMethod;

  const Config({
    this.theme: ThemePick.light,
    this.signInMethod,
  });

  Config.fromPrefs(SharedPreferences prefs)
      : theme        = getTheme(prefs),
        signInMethod = getSignInMethod(prefs);

  ThemeData get themeData {
    switch (theme) {
      case ThemePick.light:
        return new ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal[700],
          accentColor: Colors.orangeAccent[700],
        );
      case ThemePick.dark:
        return new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent[700],
        );
    }
    return null;
  }

  Config copyWith({
    ThemePick theme,
    SignInMethod signInMethod,
    String bookId,
  }) {
    return new Config(
      theme: theme ?? this.theme,
      signInMethod: signInMethod ?? this.signInMethod,
    );
  }

  static ThemePick getTheme(SharedPreferences prefs) {
    final value = prefs.getString(kTheme) ?? kThemeLight;
    return value == kThemeLight ? ThemePick.light : ThemePick.dark;
  }

  static SignInMethod getSignInMethod(SharedPreferences prefs) {
    final value = prefs.getString(kSignInMethod);
    if (value == kSignInGoogle) {
      return SignInMethod.google;
    } else {
      return null;
    }
  }
}
