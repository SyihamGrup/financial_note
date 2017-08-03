/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/data/config.dart';
import 'package:financial_note/i18n/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static const kRouteName = '/settings';

  final Config config;
  final ValueChanged<Config> updateConfig;

  const SettingsPage(this.config, this.updateConfig);

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _handleThemeChanged(ThemePick theme) {
    var config = widget.config.copyWith(theme: theme);
    SharedPreferences.getInstance().then((prefs) {
      final themeName = theme == ThemePick.light ? Config.kThemeLight : Config.kThemeDark;
      prefs.setString(Config.kTheme, themeName);
    });
    widget.updateConfig(config);
  }

  Widget buildSettingsPane(BuildContext context) {
    return new ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: <Widget>[
        new ListTile(
          title: new Text(Lang.of(context).prefUseDark()),
          onTap: () {
            _handleThemeChanged(widget.config.theme == ThemePick.dark
                ? ThemePick.light : ThemePick.dark);
          },
          trailing:  new Switch(
            value: widget.config.theme == ThemePick.dark,
            onChanged: (bool value) {
              _handleThemeChanged(value ? ThemePick.dark : ThemePick.light);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(Lang.of(context).titleSettings())),
      body: buildSettingsPane(context),
    );
  }
}
