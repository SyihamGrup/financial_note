/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'dart:async';

import 'package:financial_note/auth.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppDrawer extends StatefulWidget {
  final String selectedRoute;
  final ValueChanged<String> onListTap;

  const AppDrawer({String selectedRoute, this.onListTap})
    :  this.selectedRoute  = selectedRoute ?? TransactionListPage.kRouteName;

  @override
  State<StatefulWidget> createState() => new _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var _isAlternateMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

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
                new Row(
                  children: [
                    new Expanded(child: new InkWell(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                      onTap: () => setState(() => _isAlternateMode = !_isAlternateMode),
                    )),
                    new IconButton(
                      icon: _isAlternateMode ? const Icon(Icons.arrow_drop_up)
                                             : const Icon(Icons.arrow_drop_down),
                      color: Colors.white,
                      onPressed: () => setState(() => _isAlternateMode = !_isAlternateMode),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]..addAll(!_isAlternateMode ? _getMenu() : _getAlternateMenu()),
      ),
    );
  }

  List<Widget> _getMenu() {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final aboutTextStyle = theme.textTheme.body2;
    final linkStyle = aboutTextStyle.copyWith(color: theme.accentColor);

    return [
      new ListTile(
        leading: kIconHome,
        title: new Text(lang.drawerHome()),
        selected: widget.selectedRoute == TransactionListPage.kRouteName,
        onTap: () => listTapped(context, TransactionListPage.kRouteName),
      ),

      new ListTile(
        leading: kIconBill,
        title: new Text(lang.drawerBills()),
        selected: widget.selectedRoute == BillListPage.kRouteName,
        onTap: () => listTapped(context, BillListPage.kRouteName),
      ),

      new ListTile(
        leading: kIconBudget,
        title: new Text(lang.drawerBudgets()),
        selected: widget.selectedRoute == BudgetListPage.kRouteName,
        onTap: () => listTapped(context, BudgetListPage.kRouteName),
      ),

      new ListTile(
        leading: kIconNote,
        title: new Text(lang.drawerNotes()),
        selected: widget.selectedRoute == NoteListPage.kRouteName,
        onTap: () => listTapped(context, NoteListPage.kRouteName),
      ),

      const Divider(),

      new ListTile(
        title: new Text(lang.drawerSettings()),
        onTap: () => listTapped(context, SettingsPage.kRouteName),
      ),

      new ListTile(
        title: new Text(lang.drawerHelp()),
        onTap: () => showHelpDialog(),
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
      ),
    ];
  }

  List<Widget> _getAlternateMenu() {
    final lang = Lang.of(context);
    return [
      new ListTile(
        leading: kIconSignOut,
        title: new Text(lang.drawerLogout()),
        onTap: () => signOut().then((_) {
          Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
        }),
      ),
    ];
  }

  Future<Null> showHelpDialog() async {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final aboutTextStyle = theme.textTheme.body2;
    final linkStyle = aboutTextStyle.copyWith(color: theme.accentColor);

    await showDialog(context: context, child: new AlertDialog(
      title: new Text(lang.drawerHelp()),
      content: new RichText(text: new TextSpan(children: [
        new TextSpan(text: lang.msgHelp(), style: aboutTextStyle),
        new TextSpan(text: ' adisayoga@gmail.com', style: linkStyle),
      ])),
      actions: [
        new FlatButton(
           child: new Text(lang.btnClose().toUpperCase()),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ));
  }

  void listTapped(BuildContext context, String routeName) {
    Navigator.pop(context); // Close drawer
    if (widget.selectedRoute == routeName) return;
    if (widget.onListTap != null) widget.onListTap(routeName);
  }
}
