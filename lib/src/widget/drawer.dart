/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppDrawer extends StatelessWidget {
  final String selectedRoute;
  final ValueChanged<String> onListTap;

  const AppDrawer({String selectedRoute, this.onListTap})
    :  this.selectedRoute  = selectedRoute ?? TransactionListPage.kRouteName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final aboutTextStyle = theme.textTheme.body2;
    final linkStyle = aboutTextStyle.copyWith(color: theme.accentColor);

    return new Drawer(
      child: new ListView(
        children: [
          new DrawerHeader(
            decoration: new BoxDecoration(image: new DecorationImage(
              image: new ExactAssetImage('assets/drawer_header.jpg'),
              fit: BoxFit.cover,
            )),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(lang.title(), style: theme.textTheme.headline.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 28.0,
                )),
                new Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new Text(currentUser?.displayName,
                    style: theme.textTheme.body2.copyWith(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                ),
                new Text(currentUser?.email, style: theme.textTheme.body1.copyWith(
                  color: Colors.blueGrey[50],
                )),
              ]
            ),
          ),
          new ListTile(
            leading: kIconHome,
            title: new Text(lang.drawerHome()),
            selected: selectedRoute == TransactionListPage.kRouteName,
            onTap: () => listTapped(context, TransactionListPage.kRouteName),
          ),

          new ListTile(
            leading: kIconBill,
            title: new Text(lang.drawerBills()),
            selected: selectedRoute == BillListPage.kRouteName,
            onTap: () => listTapped(context, BillListPage.kRouteName),
          ),

          new ListTile(
            leading: kIconBudget,
            title: new Text(lang.drawerBudgets()),
            selected: selectedRoute == BudgetListPage.kRouteName,
            onTap: () => listTapped(context, BudgetListPage.kRouteName),
          ),

          new ListTile(
            leading: kIconNote,
            title: new Text(lang.drawerNotes()),
            selected: selectedRoute == NoteListPage.kRouteName,
            onTap: () => listTapped(context, NoteListPage.kRouteName),
          ),

          const Divider(),

          new ListTile(
            title: new Text(lang.drawerSettings()),
            onTap: () => listTapped(context, SettingsPage.kRouteName),
          ),

          new ListTile(
            title: new Text(lang.drawerHelp()),
            onTap: () => listTapped(context, null),
          ),

          new AboutListTile(
            icon: null,
            applicationVersion: 'July 2017 Preview',
            applicationLegalese: '© 2017 Adi Sayoga',
            aboutBoxChildren: [new Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: new RichText(text: new TextSpan(children: [
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
