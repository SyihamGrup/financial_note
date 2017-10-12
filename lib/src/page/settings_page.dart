/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page;

class SettingsPage extends StatelessWidget {
  static const kRouteName = '/settings';

  final Config config;
  final ValueChanged<Config> updateConfig;

  const SettingsPage(this.config, this.updateConfig);

  Widget buildSettingsPane(BuildContext context) {
    return new ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: <Widget>[
        new ListTile(
          title: new Text(Lang.of(context).prefUseDark()),
          onTap: () {
            _handleThemeChanged(config.theme == ThemeName.dark
                ? ThemeName.light : ThemeName.dark);
          },
          trailing: new Switch(
            value: config.theme == ThemeName.dark,
            onChanged: (bool value) {
              _handleThemeChanged(value ? ThemeName.dark : ThemeName.light);
            },
          ),
        )
      ],
    );
  }

  void _handleThemeChanged(ThemeName theme) {
    final newConfig = config.copyWith(theme: theme);
    SharedPreferences.getInstance().then((prefs) {
      final themeStr = theme == ThemeName.light ? kPrefThemeLight : kPrefThemeDark;
      prefs.setString(kPrefTheme, themeStr);
    });
    updateConfig(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(Lang.of(context).titleSettings())),
      body: buildSettingsPane(context),
    );
  }
}
