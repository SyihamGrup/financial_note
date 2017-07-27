// Copyright (c) 2017. All rights reserved.
//
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//
// Written by:
//   - Adi Sayoga <adisayoga@gmail.com>

import 'package:financial_note/i18n/strings.dart';
import 'package:financial_note/page/settings_page.dart';
import 'package:flutter/material.dart';

import 'widget.dart';

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
              child: new Text(Lang.of(context).title(), style: theme.textTheme.headline.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w300,
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
            applicationVersion: 'July 2017 Preview',
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
