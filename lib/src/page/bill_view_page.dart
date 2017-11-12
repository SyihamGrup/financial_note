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
    _groupSubscr = getNode(BillGroup.kNodeName, widget.bookId).child(widget.id)
                   .onValue.listen((event) {
      _initData();
    });
    _itemSubscr = getNode(Bill.kNodeName, widget.bookId).orderByChild('groupId')
                  .equalTo(widget.id).onValue.listen((event) {
      _initData();
    });
  }

  Future<Null> _initData() async {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final currencySymbol = widget.config.currencySymbol;

    _group = await BillGroup.of(widget.bookId).get(widget.id);
    if (_group == null) return;
    _items = await BillGroup.of(widget.bookId).getItems(_group.id);
    _widgets = <Widget>[];

    final dateFormatter = new DateFormat.yMMMEd();
    final shortDateFormatter = new DateFormat.yMd();

    _widgets.add(_buildItemText(
      _group.transType == kIncome ? lang.lblIncome() : lang.lblExpense(),
      label: lang.lblType()
    ));

    final totalWidgets = <Widget>[
      _buildItemText(
        formatCurrency(_group.totalValue, symbol: widget.config.currencySymbol),
        label: lang.lblTotal(),
      ),
    ];
    if (_group.paidValue != 0) {
      totalWidgets.add(_buildItemText(
        formatCurrency(_group.paidValue, symbol: widget.config.currencySymbol),
        label: lang.lblPaid(),
      ));
    }
    _widgets.add(new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: totalWidgets,
    ));

    if (_items.length > 1) {
      _widgets.add(new Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: new Divider(height: 0.0),
      ));

      for (final item in _items) {
        var subtitle = shortDateFormatter.format(item.date);
        if (item.paidDate != null) {
          subtitle += '   '
                   + lang.lblPaid() + ': ' + shortDateFormatter.format(item.paidDate);
        }
        if (item.paidValue != 0 && item.value != item.paidValue) {
          subtitle += ' (' + formatCurrency(item.paidValue, symbol: currencySymbol) + ')';
        }
        _widgets.add(new Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: new Icon(item.paidValue > 0 ? Icons.check : Icons.remove),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(item.title, style: theme.textTheme.subhead),
                    new Text(subtitle, style: theme.textTheme.caption),
                  ],
                ),
              ),
              new Text(formatCurrency(item.value, symbol: currencySymbol),
                       style: theme.textTheme.subhead),
            ],
          ),
        ));
      }
      _widgets.add(new Divider());
    } else if (_items.length == 1) {
      final item = _items[0];
      _widgets.add(_buildItemText(
        dateFormatter.format(item.date), label: lang.lblDate()
      ));
      if (_group.title != item.title) {
        _widgets.add(_buildItemText(item.title, label: lang.lblBillPeriod()));
      }
      _widgets.add(_buildItemText(
        formatCurrency(item.value, symbol: currencySymbol),
        label: lang.lblValue())
      );
      if (item.paidDate != null) {
        _widgets.add(_buildItemText(
          dateFormatter.format(item.paidDate), label: lang.lblPaid())
        );
      }
      if (item.paidValue != 0) {
        _widgets.add(_buildItemText(
          formatCurrency(item.paidValue, symbol: currencySymbol),
          label: lang.lblPaid())
        );
      }
    }

    _widgets.add(new Row(
      children: <Widget>[
        new Expanded(child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildItemText(_group.note, label: lang.lblNone(), margin: 0.0),
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
              Navigator.pushNamed(context, buildRoute(BillPage.kRouteName, params));
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
    if (_groupSubscr != null) _groupSubscr.cancel();
    if (_itemSubscr != null) _itemSubscr.cancel();
  }
}
