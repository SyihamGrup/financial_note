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

class BillViewPage extends StatefulWidget {
  static const kRouteName = '/view-bill';
  final Config config;
  final String bookId;
  final String id;

  BillViewPage({@required this.config, @required this.bookId, @required this.id})
    : assert(config != null), assert(bookId != null), assert(id != null);

  @override
  State<StatefulWidget> createState() => new _BillViewPage();
}

class _BillViewPage extends State<BillViewPage> {
  StreamSubscription<Event> _groupSubscr;
  StreamSubscription<Event> _itemSubscr;

  BillGroup _group;
  List<Bill> _items;
  List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    _groupSubscr = BillGroup.getNode(widget.bookId).child(widget.id)
                            .onValue.listen((event) {
      _initData();
    });
    _itemSubscr = Bill.getNode(widget.bookId).orderByChild('groupId')
                      .equalTo(widget.id).onValue.listen((event) {
      _initData();
    });
  }

  Future<Null> _initData() async {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    _group = await BillGroup.get(widget.bookId, widget.id);
    if (_group == null) return;
    _items = await BillGroup.getItems(widget.bookId, _group.id);
    _widgets = <Widget>[];

    final dateFormatter = new DateFormat.yMMMMd();

    _widgets.add(_buildItemText(
      _group.transType == kIncome ? lang.lblIncome() : lang.lblExpense(),
      lang.lblType()
    ));
    if (_items.length > 1) {
      _widgets.add(new Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: new Divider(height: 0.0),
      ));

      for (final item in _items) {
        _widgets.add(new Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(item.title, style: theme.textTheme.subhead),
                    new Text(dateFormatter.format(item.date),
                             style: theme.textTheme.caption),
                  ],
                ),
              ),
              new Text(formatCurrency(item.value, symbol: widget.config.currencySymbol),
                       style: theme.textTheme.subhead),
            ],
          ),
        ));
      }
      _widgets.add(new Divider());
    } else if (_items.length == 1) {
      _widgets.add(_buildItemText(dateFormatter.format(_items[0].date), lang.lblDate()));
      _widgets.add(_buildItemText(_items[0].title, lang.lblBillPeriod()));
      _widgets.add(_buildItemText(
        formatCurrency(_items[0].value, symbol: widget.config.currencySymbol),
        lang.lblValue())
      );
    }

    _widgets.add(new Row(
      children: <Widget>[
        new Expanded(child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildItemText(_group.note, lang.lblNone(), 0.0),
          ],
        )),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.getItemTheme(context);
    final lang = Lang.of(context);
    final title = _group?.title ?? '';

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
              final params = <String, dynamic>{'id': _group.id};
              Navigator.pushNamed(context, routeWithParams(BillPage.kRouteName, params));
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

  @override
  void dispose() {
    super.dispose();
    if (_groupSubscr != null) _groupSubscr.cancel();
    if (_itemSubscr != null) _itemSubscr.cancel();
  }
}
