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

  void _handleThemeChanged(ThemePick theme) {
    final newConfig = config.copyWith(theme: theme);
    SharedPreferences.getInstance().then((prefs) {
      final themeName = theme == ThemePick.light ? Config.kThemeLight : Config.kThemeDark;
      prefs.setString(Config.kTheme, themeName);
    });
    updateConfig(newConfig);
  }

  Widget buildSettingsPane(BuildContext context) {
    return new ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: <Widget>[
        new ListTile(
          title: new Text(Lang.of(context).prefUseDark()),
          onTap: () {
            _handleThemeChanged(config.theme == ThemePick.dark
                ? ThemePick.light : ThemePick.dark);
          },
          trailing: new Switch(
            value: config.theme == ThemePick.dark,
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
