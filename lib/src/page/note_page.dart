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

import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NotePage extends StatefulWidget {
  static const kRouteName = '/note';

  final String bookId;
  final String id;
  final DatabaseReference ref;

  NotePage({Key key, @required this.bookId, this.id})
    : assert(bookId != null),
      ref = Note.ref(bookId),
      super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _NotePageState(id: id);
  }
}

class _NotePageState extends State<NotePage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  var _item = new Note(createdAt: new DateTime.now());
  var _ctrl = <String, TextEditingController>{
    'title': new TextEditingController(),
    'note': new TextEditingController(),
  };

  var _autoValidate = false;
  var _saveNeeded = true;

  _NotePageState({String id}) {
    _item.id = id;
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    if (_item.id == null) return;

    final snap = await widget.ref.child(_item.id).once();
    if (snap.value == null) return;
    _item = new Note.fromSnapshot(snap);
    if (_item.createdAt == null) _item.createdAt = new DateTime.now();
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
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      _showInSnackBar(Lang.of(context).msgFormError());
      return false;
    }

    _showInSnackBar(Lang.of(context).msgSaving());
    form.save();
    _item.updatedAt = new DateTime.now();
    final newItem = _item.id != null ? widget.ref.child(_item.id) : widget.ref.push();
    newItem.set(_item.toJson());

    _showInSnackBar(Lang.of(context).msgSaved());
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
    final saved = await _handleSubmitted();
    if (!saved) return await showLeaveConfirmDialog(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new IconButton(icon: kIconClose, onPressed: () {
          setState(() => _saveNeeded = false);
          nav.pop();
        }),
        title: new Text(_item.id == null ? lang.titleAddNote() : lang.titleEditNote()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => _handleSubmitted().then((saved) {
              if (saved) Navigator.pop(context);
            }),
            child: new Text(lang.btnSave().toUpperCase(), style: theme.primaryTextTheme.button),
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
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          // -- title --
          new TextFormField(
            initialValue: _ctrl['title'].text,
            controller: _ctrl['title'],
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => _item.title = value,
            validator: _validateTitle,
            autofocus: _item.id == null,
          ),

          // -- note --
          new TextFormField(
            initialValue: _ctrl['note'].text,
            controller: _ctrl['note'],
            maxLines: 15,
            decoration: new InputDecoration(labelText: lang.lblDescr()),
            onSaved: (String value) => _item.note = value,
            validator: _validateNote,
          ),
        ],
      ),
    );
  }
}
