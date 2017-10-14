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

class BudgetPage extends StatefulWidget {
  static const kRouteName = '/budget';

  final Budget _item;
  final String bookId;
  final DatabaseReference ref;

  BudgetPage({Key key, @required this.bookId, Budget item})
    : assert(bookId != null),
      this._item = item ?? new Budget(title: '', date: new DateTime.now(), value: 0.0),
      ref = Budget.ref(bookId),
      super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _BudgetPageState(_item);
  }
}

class _BudgetPageState extends State<BudgetPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  Budget _item;

  var _autoValidate = false;
  var _saveNeeded = false;

  _BudgetPageState(this._item);

  Future<Null> _handleSubmitted() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      _showInSnackBar(Lang.of(context).msgFormError());
      return;
    }

    form.save();
    final newItem = _item.id != null ? widget.ref.child(_item.id) : widget.ref.push();
    newItem.set(_item.toJson());

    _showInSnackBar(Lang.of(context).msgSaved());
    Navigator.pop(context);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  Widget _buildForm(BuildContext context) {
    final lang = Lang.of(context);

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: () async {
        if (_saveNeeded) _handleSubmitted();
        return true;
      },
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          // -- title --
          new Container(margin: const EdgeInsets.only(top: 0.0), child: new TextFormField(
            initialValue: _item.title ?? '',
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => _item.title = value,
            validator: _validateTitle,
            autofocus: true,
          )),

          // -- date --
          new Container(margin: const EdgeInsets.only(top: 8.0), child: new DateFormField(
            label: lang.lblDate(),
            date: _item.date,
            onChanged: (DateTime value) {
              _item.date = value;
              _saveNeeded = true;
            }
          )),

          // -- value --
          new Container(margin: const EdgeInsets.only(top: 8.0), child: new TextFormField(
            initialValue: _item.value?.toString() ?? '',
            decoration: new InputDecoration(labelText: lang.lblValue()),
            keyboardType: TextInputType.number,
            onSaved: (String value) => _item.value = double.parse(value),
            validator: _validateTitle,
          )),

          // -- descr --
          new Container(margin: const EdgeInsets.only(top: 8.0), child: new TextFormField(
            initialValue: _item.descr ?? '',
            decoration: new InputDecoration(labelText: lang.lblDescr()),
            onSaved: (String value) => _item.descr = value,
          )),
        ],
      ),
    );
  }

  String _validateTitle(String value) {
    _saveNeeded = true;
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
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
        title: new Text(lang.titleAddBudget()),
        actions: <Widget>[
          new FlatButton(
            onPressed: _handleSubmitted,
            child: new Text(lang.btnSave().toUpperCase(), style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }
}
