import 'package:flutter/material.dart';

import '../strings.dart';
import '../helpers/widget.dart';
import 'settings_page.dart';

class AppDrawer extends StatefulWidget {
  @override
  AppDrawerState createState() => new AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aboutTextStyle = theme.textTheme.body2;
    final linkStyle = aboutTextStyle.copyWith(color: theme.accentColor);

    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new DrawerHeader(
            decoration: new BoxDecoration(image: new DecorationImage(
              image: new ExactAssetImage('assets/drawer_header.jpg'),
              fit: BoxFit.cover,
            )),
            child: new Container(
              alignment: FractionalOffset.bottomLeft,
              child: new Text(Lang.of(context).title(), style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w200,
                fontSize: 25.0,
              )),
            ),
          ),

          new ListTile(
            leading: const Icon(Icons.home),
            title: new Text(Lang.of(context).drawerHome()),
            selected: true,
          ),

          const Divider(),

          new ListTile(
            title: new Text(Lang.of(context).drawerSettings()),
            onTap: () => Navigator.popAndPushNamed(context, SettingsPage.routeName),
          ),

          new ListTile(
            title: new Text(Lang.of(context).drawerHelp()),
          ),

          new AboutListTile(
            icon: null,
            applicationVersion: 'Jully 2017 Preview',
            applicationLegalese: '© 2017 Adi Sayoga',
            aboutBoxChildren: <Widget>[new Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: new RichText(text: new TextSpan(children: <TextSpan>[
                new TextSpan(
                  text: 'Flutter is an early-stage, open-source project to help '
                        'developers build high-performance, high-fidelity, mobile '
                        'apps for iOS and Android from a single codebase. '
                        'This financial note is an experiment to build application '
                        'to record financial transactions.',
                  style: aboutTextStyle,
                ),
                new TextSpan(
                  text: '\n\nLearn more about Flutter at ',
                  style: aboutTextStyle,
                ),
                new LinkTextSpan(url: 'https://flutter.io', style: linkStyle),
                new TextSpan(style: aboutTextStyle, text: '.')
              ])),
            )],
          )
        ],
      ),
    );
  }
}
