/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/config.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/src/page/balance_list_page.dart';
import 'package:financial_note/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  static const kRouteName = '/settings';

  final Config config;
  final ValueChanged<Config> updater;

  const SettingsPage({Key key, @required this.config, @required this.updater})
    : assert(config != null),
      assert(updater != null),
      super(key: key);

  Widget buildSettingsPane(BuildContext context) {
    final lang = Lang.of(context);

    return new ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: <Widget>[
        new ListTile(
          title: new Text(lang.prefUseDark()),
          onTap: () {
            _handleThemeChanged(config.brightness == Brightness.dark
                ? Brightness.light : Brightness.dark);
          },
          trailing: new Switch(
            value: config.brightness == Brightness.dark,
            onChanged: (bool value) {
              _handleThemeChanged(value ? Brightness.dark : Brightness.light);
            },
          ),
        ),
        new ListTile(
          title: new Text(lang.prefMonthlyBalance()),
          subtitle: new Text(lang.prefMonthlyBalanceDescr()),
          onTap: () => Navigator.pushNamed(context, BalanceListPage.kRouteName),
        ),
      ],
    );
  }

  void _handleThemeChanged(Brightness brightness) {
    final newConfig = config.copyWith(brightness: brightness);
    SharedPreferences.getInstance().then((prefs) {
      final themeStr = brightness == Brightness.light ? kPrefThemeLight : kPrefThemeDark;
      prefs.setString(kPrefTheme, themeStr);
    });
    updater(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: config.getSettingTheme(context).appBarBackground,
        title: new Text(Lang.of(context).titleSettings())
      ),
      body: buildSettingsPane(context),
    );
  }
}
