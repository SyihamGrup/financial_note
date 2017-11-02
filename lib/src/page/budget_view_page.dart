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
    final lang = Lang.of(context);

    _item = await Budget.get(widget.bookId, widget.id);
    if (_item == null) return;
    _transactions = await _item.getTransactions(widget.bookId);
    _widgets = <Widget>[];

    final textTheme = Theme.of(context).textTheme;
    final dateFormatter = new DateFormat.yMMMMd();
    final currFormatter = new NumberFormat.currency(symbol: widget.config.currencySymbol);

    _widgets.add(_buildItemText(
      textTheme, lang.lblDate(), dateFormatter.format(_item.date))
    );
    _widgets.add(_buildItemText(
      textTheme, lang.lblValue(), currFormatter.format(_item.value))
    );

    for (final trans in _transactions) {
      _widgets.add(new Text(trans.title));
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
            child: new Text(lang.btnEdit(),
                            style: theme.appBarTextTheme.button),
          ),
        ],
      ),
      body: _widgets != null && _widgets.length > 0
        ? new ListView(
          padding: const EdgeInsets.all(16.0),
          children: _widgets,
        )
        : const EmptyBody(isLoading: true),
    );
  }

  Widget _buildItemText(TextTheme theme, label, String value) {
    return new Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(label, style: theme.caption),
          new Text(value, style: theme.subhead),
        ],
      ),
    );
  }
}
