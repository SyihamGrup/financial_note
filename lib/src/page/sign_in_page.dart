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
import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  static const kRouteName = '/sign-in';

  const SignInPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var _signingIn = false;

  Future<Null> signIn(BuildContext context) async {
    setState(() => _signingIn = true);

    final google = await signInWithGoogle();
    if (google != null) {
      analytics.logLogin();

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(kPrefSignInMethod, kPrefSignInGoogle);

      final c = await google.authentication;
      currentUser = await auth.signInWithGoogle(
        idToken: c.idToken,
        accessToken: c.accessToken
      );
      if (currentUser != null) {
        currentBook = await getBook(currentUser);
        assert(currentBook != null);
        Navigator.pushReplacementNamed(context, HomePage.kRouteName);
      }
    }

    setState(() => _signingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final msg = _signingIn ? lang.msgWait() : lang.msgSignInRequired();

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: theme.primaryColor),
        padding: new EdgeInsets.fromLTRB(32.0, MediaQuery.of(context).padding.top + 16.0, 32.0, 16.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            new Text(lang.title(), style: theme.primaryTextTheme.display1),
            new Container(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: new Text(msg, style: theme.primaryTextTheme.body1),
            ),
            new Row(children: <Widget>[
              new Expanded(child: new RaisedButton(
                onPressed: !_signingIn ? () => signIn(context) : null,
                child: new Text(lang.btnSignInGoogle(), style: theme.accentTextTheme.button),
                color: theme.accentColor,
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
