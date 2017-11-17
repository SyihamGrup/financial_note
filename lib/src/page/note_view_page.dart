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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class NoteViewPage extends StatefulWidget {
  static const kRouteName = '/view-note';
  final Config config;
  final String bookId;
  final String id;

  NoteViewPage({@required this.config, @required this.bookId, @required this.id})
    : assert(config != null), assert(bookId != null), assert(id != null);

  @override
  State<StatefulWidget> createState() => new _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  StreamSubscription<Event> _dataSubscr;
  Note _item;
  List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    _dataSubscr = getNode(Note.kNodeName, widget.bookId).child(widget.id)
                  .onValue.listen((event) {
      _initData();
    });
  }

  Future<Null> _initData() async {
    final lang = Lang.of(context);

    _item = await Note.of(widget.bookId).get(widget.id);
    if (_item == null) return;
    _widgets = [];

    _widgets.add(_buildItemText(_item.note));

    if (_item.reminder != null) {
      _widgets.add(_buildItemText(
        new DateFormat.yMMMMd().format(_item.reminder), label: lang.lblReminder()
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
              Navigator.pushNamed(context, buildRoute(NotePage.kRouteName, params));
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
