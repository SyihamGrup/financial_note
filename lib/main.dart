import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/types.dart';
import 'i18n/lang_messages_all.dart';
import 'i18n/strings.dart';
import 'widget/home_page.dart';
import 'widget/settings_page.dart';

void main() {
  runApp(new MainApp());
}

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => new MainAppState();
}

class MainAppState extends State<MainApp> {
  var _config = new Config();

  ThemeData get theme {
    switch (_config.theme) {
      case AppTheme.light:
        return new ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal[700],
          accentColor: Colors.tealAccent[700],
        );
      case AppTheme.dark:
        return new ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.tealAccent,
        );
    }
    return null;
  }

  Route<Null> _getRoute(RouteSettings settings) {
    return new MaterialPageRoute<Null>(
      settings: settings,
      builder: (BuildContext context) {
        if (settings.name == SettingsPage.routeName) {
          return new SettingsPage(_config, configUpdater);
        }
        return new HomePage(_config, configUpdater);
      }
    );
  }

  void configUpdater(Config value) {
    setState(() => _config = value);
  }

  Future<LocaleQueryData> _onLocaleChanged(Locale locale) async {
    final localeString = locale.toString();
    await initializeMessages(localeString);
    Intl.defaultLocale = localeString;
    return Lang.instance;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Financial Note',
      theme: theme,
      debugShowMaterialGrid: _config.debugShowGrid,
      showPerformanceOverlay: _config.showPerformanceOverlay,
      showSemanticsDebugger: _config.showSemanticsDebugger,
      onGenerateRoute: _getRoute,
      onLocaleChanged: _onLocaleChanged
    );
  }
}
