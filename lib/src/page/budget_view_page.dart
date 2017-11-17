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
import 'package:financial_note/utils.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/firebase_database.dart';
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
  State<StatefulWidget> createState() => new _BudgetViewPageState();
}

class _BudgetViewPageState extends State<BudgetViewPage> {
  StreamSubscription<Event> _dataSubscr;
  Budget _item;
  List<Transaction> _transactions;
  List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    _dataSubscr = getNode(Budget.kNodeName, widget.bookId).child(widget.id)
                  .onValue.listen((event) {
      _initData();
    });
  }

  Future<Null> _initData() async {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    _item = await Budget.of(widget.bookId).get(widget.id);
    if (_item == null) return;
    _transactions = await _item.getTransactions();
    _widgets = [];

    final dateFormatter = new DateFormat.yMMMMd();

    _widgets.add(_buildItemText(
      dateFormatter.format(_item.date), label: lang.lblDate()
    ));

    final totalWidgets = [
      _buildItemText(
        formatCurrency(_item.value, symbol: widget.config.currencySymbol),
        label: lang.lblValue(),
      ),
    ];
    if (_item.spent != 0) {
      totalWidgets.add(_buildItemText(
        formatCurrency(_item.spent, symbol: widget.config.currencySymbol),
        label: lang.lblSpent(),
      ));
    }
    _widgets.add(new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: totalWidgets,
    ));

    _widgets.add(_buildItemText(_item.descr, label: lang.lblDescr()));

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
          children: [
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Text(trans.title, style: theme.textTheme.subhead),
                  new Text(dateFormatter.format(trans.date),
                           style: theme.textTheme.caption),
                ],
              ),
            ),
            new Text((trans.value > 0 ? '+' : '') +
                     formatCurrency(trans.value, symbol: widget.config.currencySymbol),
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
        actions: [
          new FlatButton(
            onPressed: () {
              final params = {'id': _item.id};
              Navigator.pushNamed(context, buildRoute(BudgetPage.kRouteName, params));
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

  Widget _buildItemText(String value, {
    String label,
    double margin = 10.0,
    CrossAxisAlignment align: CrossAxisAlignment.start
  }) {
    final textTheme = Theme.of(context).textTheme;
    final children = <Widget>[];
    if (label != null) children.add(new Text(label, style: textTheme.caption));
    children.add(new Text(value, style: textTheme.subhead));
    return new Padding(
      padding: new EdgeInsets.fromLTRB(16.0, 0.0, 16.0, margin),
      child: new Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_dataSubscr != null) _dataSubscr.cancel();
  }
}
