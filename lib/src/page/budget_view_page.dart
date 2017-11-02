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
import 'package:financial_note/widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetViewPage extends StatefulWidget {
  static const kRouteName = '/view-budget';
  final Config config;
  final String bookId;
  final String id;

  BudgetViewPage({@required this.config, @required this.bookId, @required this.id})
    : assert(config != null), assert(bookId != null), assert(id != null);

  @override
  State<StatefulWidget> createState() => new _BudgetViewPage();
}

class _BudgetViewPage extends State<BudgetViewPage> {
  Budget _item;
  List<Transaction> _transactions;
  List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    _item = await Budget.get(widget.bookId, widget.id);
    if (_item == null) return;
    _transactions = await _item.getTransactions(widget.bookId);
    _widgets = <Widget>[];

    final dateFormatter = new DateFormat.yMMMMd();
    final currFormatter = new NumberFormat.currency(symbol: widget.config.currencySymbol);

    _widgets.add(new Row(
      children: <Widget>[
        new Expanded(child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildItemText(dateFormatter.format(_item.date), lang.lblDate()),
            _buildItemText(_item.descr, lang.lblDescr()),
          ],
        )),
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildItemText(currFormatter.format(_item.value), lang.lblValue()),
            _buildItemText(currFormatter.format(_item.spent), lang.lblSpent()),
          ],
        ),
      ],
    ));

    if (_transactions.length > 0) {
      _widgets.add(new Divider());
      _widgets.add(new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Text(lang.lblTransactions(), style: theme.textTheme.caption)
      ));
    }

    for (final trans in _transactions) {
      _widgets.add(new Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(trans.title, style: theme.textTheme.subhead),
                  new Text(dateFormatter.format(trans.date),
                           style: theme.textTheme.caption),
                ],
              ),
            ),
            new Text((trans.value > 0 ? '+' : '') + currFormatter.format(trans.value),
                     style: theme.textTheme.subhead),
          ],
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.getItemTheme(context);
    final lang = Lang.of(context);
    final title = _item?.title ?? '';

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: theme.appBarBackground,
        textTheme: theme.appBarTextTheme,
        iconTheme: theme.appBarIconTheme,
        elevation: theme.appBarElevation,
        title: new Text(title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              final params = <String, dynamic>{'id': _item.id};
              Navigator.pushNamed(context, routeWithParams(BudgetPage.kRouteName, params));
            },
            child: new Text(lang.btnEdit().toUpperCase(),
                            style: theme.appBarTextTheme.button),
          ),
        ],
      ),
      body: _widgets != null && _widgets.length > 0
        ? new SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: new Card(child: new Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            width: double.INFINITY,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _widgets
            ),
          )),
        )
        : const EmptyBody(isLoading: true),
    );
  }

  Widget _buildItemText(String value, [label, double margin = 10.0]) {
    final textTheme = Theme.of(context).textTheme;
    final children = <Widget>[];
    if (label != null) children.add(new Text(label, style: textTheme.caption));
    children.add(new Text(value, style: textTheme.subhead));
    return new Padding(
      padding: new EdgeInsets.fromLTRB(16.0, 0.0, 16.0, margin),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
