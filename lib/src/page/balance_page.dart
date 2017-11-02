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

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BalancePage extends StatefulWidget {
  static const kRouteName = '/balance';
  final Config config;
  final String bookId;
  final String id;

  BalancePage({Key key, @required this.config, @required this.bookId, this.id})
    : assert(config != null), assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final _formKey = new GlobalKey<BalanceFormState>();
  Balance _item;

  @override initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    _item = await Balance.get(widget.bookId, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.getItemTheme(context);
    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      backgroundColor: theme.formBackground,
      appBar: new AppBar(
        backgroundColor: theme.appBarBackground,
        textTheme: theme.appBarTextTheme,
        iconTheme: theme.appBarIconTheme,
        elevation: theme.appBarElevation,
        leading: new IconButton(icon: kIconClose, onPressed: () {
          _formKey.currentState.discard();
          nav.pop();
        }),
        title: new Text(widget.id == null ? lang.titleAddBalance() : lang.titleEditBalance()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => _formKey.currentState.save().then((saved) {
              if (saved) Navigator.pop(context);
            }),
            child: new Text(lang.btnSave().toUpperCase(),
                            style: theme.appBarTextTheme.button),
          ),
        ],
      ),
      body: new BalanceForm(key: _formKey, bookId: widget.bookId, item: _item),
    );
  }
}
