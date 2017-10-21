/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppDrawer extends StatelessWidget {
  final String selectedRoute;
  final ValueChanged<String> onListTap;

  const AppDrawer({String selectedRoute, this.onListTap})
    :  this.selectedRoute  = selectedRoute ?? HomePageTransaction.kRouteName;

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
            leading: kIconHome,
            title: new Text(Lang.of(context).drawerHome()),
            selected: selectedRoute == HomePageTransaction.kRouteName,
            onTap: () => listTapped(context, HomePageTransaction.kRouteName),
          ),

          new ListTile(
            leading: kIconBill,
            title: new Text(Lang.of(context).drawerBills()),
            selected: selectedRoute == HomePageBill.kRouteName,
            onTap: () => listTapped(context, HomePageBill.kRouteName),
          ),

          new ListTile(
            leading: kIconBudget,
            title: new Text(Lang.of(context).drawerBudgets()),
            selected: selectedRoute == HomePageBudget.kRouteName,
            onTap: () => listTapped(context, HomePageBudget.kRouteName),
          ),

          new ListTile(
            leading: kIconNote,
            title: new Text(Lang.of(context).drawerNotes()),
            selected: selectedRoute == HomePageNote.kRouteName,
            onTap: () => listTapped(context, HomePageNote.kRouteName),
          ),

          const Divider(),

          new ListTile(
            title: new Text(Lang.of(context).drawerSettings()),
            onTap: () => listTapped(context, SettingsPage.kRouteName),
          ),

          new ListTile(
            title: new Text(Lang.of(context).drawerHelp()),
            onTap: () => listTapped(context, null),
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

  void listTapped(BuildContext context, String routeName) {
    Navigator.pop(context); // Close drawer
    if (selectedRoute == routeName) return;
    if (onListTap != null) onListTap(routeName);
  }
}
