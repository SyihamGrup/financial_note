import 'package:financial_note/data/config.dart';
import 'package:financial_note/i18n/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  final Config config;
  final ValueChanged<Config> updateConfig;

  const SettingsPage(this.config, this.updateConfig);

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  void _handleThemeChanged(AppTheme theme) {
    widget.updateConfig(widget.config.copyWith(theme: theme));
  }

  Widget buildSettingsPane(BuildContext context) {
    return new ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: <Widget>[
        new ListTile(
          title: new Text(Lang.of(context).prefUseDark()),
          onTap: () => _handleThemeChanged(widget.config.theme == AppTheme.light ? AppTheme.dark : AppTheme.light),
          trailing:  new Switch(
            value: widget.config.theme == AppTheme.dark,
            onChanged: (bool value) => _handleThemeChanged(value ? AppTheme.dark : AppTheme.light),
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
