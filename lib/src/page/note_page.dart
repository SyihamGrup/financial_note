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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class NotePage extends StatefulWidget {
  static const kRouteName = '/note';

  final Config config;
  final String bookId;
  final String id;

  NotePage({Key key, @required this.config, @required this.bookId, this.id})
    : assert(config != null), assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  Note _item;
  Map<String, TextEditingController> _ctrl;

  var _autoValidate = false;
  var _saveNeeded = true;
  var _hasReminder = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    _item = await Note.of(widget.bookId).get(widget.id);
    if (_item == null) _item = new Note(widget.bookId);
    _hasReminder = _item.reminder != null;
    _ctrl = <String, TextEditingController>{
      'title': new TextEditingController(text: _item.title ?? ''),
      'note': new TextEditingController(text: _item.note ?? ''),
    };
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  Future<bool> _handleSubmitted() async {
    final form = _formKey.currentState;
    try {
      form.save();
      if (_item.createdAt == null) _item.createdAt = new DateTime.now();
      _item.updatedAt = new DateTime.now();
      await _item.save();
      if (_item.reminder != null) await _item.scheduleNotification();
      return true;
    } catch (e) {
      _showInSnackBar(e.message);
      return false;
    }
  }

  bool _validate() {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      _showInSnackBar(Lang.of(context).msgFormError());
      return false;
    }
    return true;
  }

  String _validateTitle(String value) {
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
  }

  String _validateNote(String value) {
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
  }

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;
    if (!_validate()) return await showLeaveConfirmDialog(context);
    _handleSubmitted();
    return true;
  }

  void _onReminderChange(bool value) {
    setState(() {
      _hasReminder = value;
      if (!_hasReminder) {
        _item.reminder = null;
      } else if (_item.reminder == null) {
        _item.reminder = new DateTime.now().add(new Duration(days: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.config.getItemTheme(context);
    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.formBackground,
      appBar: new AppBar(
        backgroundColor: theme.appBarBackground,
        textTheme: theme.appBarTextTheme,
        iconTheme: theme.appBarIconTheme,
        elevation: theme.appBarElevation,
        leading: new IconButton(icon: kIconClose, onPressed: () {
          setState(() => _saveNeeded = false);
          nav.pop();
        }),
        title: new Text(widget.id == null ? lang.titleAddNote() : lang.titleEditNote()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              if (!_validate()) return;
              _handleSubmitted();
              Navigator.pop(context);
            },
            child: new Text(lang.btnSave().toUpperCase(),
                            style: theme.appBarTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final lang = Lang.of(context);

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: _onWillPop,
      child: new SingleChildScrollView(
        child: new Column(children: [
          // -- title --
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: new TextFormField(
              initialValue: _ctrl != null ? _ctrl['title'].text : '',
              controller: mapValue(_ctrl, 'title'),
              decoration: new InputDecoration(labelText: lang.lblTitle()),
              onSaved: (String value) => _item.title = value,
              validator: _validateTitle,
              autofocus: widget.id == null,
            ),
          ),

          // -- reminder
          _buildReminder(),

          // -- note --
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: new TextFormField(
              initialValue: _ctrl != null ? _ctrl['note'].text : '',
              controller: mapValue(_ctrl, 'note'),
              maxLines: 15,
              decoration: new InputDecoration(labelText: lang.lblDescr()),
              onSaved: (String value) => _item.note = value,
              validator: _validateNote,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildReminder() {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    final widgets = <Widget>[
      new Checkbox(value: _hasReminder, onChanged: _onReminderChange),
      new GestureDetector(
        child: new Text(lang.lblReminder(), style: theme.textTheme.subhead),
        onTap: () => _onReminderChange(!_hasReminder),
      ),
    ];
    if (_hasReminder) {
      widgets.add(new Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: new DateTimeItem(
          dateTime: _item.reminder,
          dateFormat: new DateFormat.MMMd(),
          onChange: (DateTime value) => _item.reminder = value,
        )
      ));
    }
    return new Row(children: widgets);
  }
}
