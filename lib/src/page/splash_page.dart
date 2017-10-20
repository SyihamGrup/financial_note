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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  static const kRouteName = '/splash';

  const SplashPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _subtitle;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<Null> _init() async {
    try {
      currentUser = await ensureLoggedIn();

      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
        return;
      }
      currentBook = await _getBook();
      assert(currentBook != null);

      final ref = FirebaseDatabase.instance.reference();
      ref.child(Book.kNodeName).child(currentUser.uid).keepSynced(true);
      ref.child(Budget.kNodeName).child(currentBook.id).keepSynced(true);
      ref.child(Bill.kNodeName).child(currentBook.id).keepSynced(true);
      ref.child(Balance.kNodeName).child(currentBook.id).keepSynced(true);
      ref.child(Transaction.kNodeName).child(currentBook.id).keepSynced(true);

      Navigator.pushReplacementNamed(context, HomePage.kRouteName);
    } catch (e) {
      setState(() => _subtitle = e.message);
    }
  }

  Future<Book> _getBook() async {
    final book = await getDefaultBook(currentUser.uid);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kPrefBookId, book?.id);
    return book;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _subtitle = _subtitle == null ? Lang.of(context).msgLoading() : _subtitle;

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: theme.primaryColor),
        child: new Center(child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Text(Lang.of(context).title(), style: theme.primaryTextTheme.display1),
            new Text(_subtitle,
              textAlign: TextAlign.center,
              style: theme.primaryTextTheme.body1.copyWith(color: Colors.white70)
            ),
          ]
        )),
      ),
    );
  }
}
