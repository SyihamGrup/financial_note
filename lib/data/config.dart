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

class Config {
  static const kFirebaseHost = 'us-central1-financialnote-d6d95.cloudfunctions.net';
  static const kFirebaseUriScheme = 'https';

  static const kOpeningBalancePath = '/getOpeningBalance';

  static const kCurrentUserId = 'currentUserId';
  static const kTheme = 'theme';
  static const kThemeLight = 'light';
  static const kThemeDark = 'dark';
  static const kBookId = 'bookId';

  final ThemePick theme;
  final String bookId;

  Config({
    this.theme: ThemePick.light,
    this.bookId,
  });

  Config.fromPrefs(SharedPreferences prefs)
      : theme = (prefs.getString(kTheme) ?? kThemeLight) == kThemeLight
                     ? ThemePick.light : ThemePick.dark,
        bookId = prefs.getString(kBookId);

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
    String bookId,
  }) {
    return new Config(
      theme: theme ?? this.theme,
      bookId: bookId ?? this.bookId,
    );
  }
}
