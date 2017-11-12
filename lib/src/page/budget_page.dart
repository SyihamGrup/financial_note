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
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class BudgetPage extends StatefulWidget {
  static const kRouteName = '/budget';

  final Config config;
  final String bookId;
  final String id;

  BudgetPage({Key key, @required this.config, @required this.bookId, this.id})
    : assert(config != null), assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  Budget _item;
  Map<String, TextEditingController> _ctrl;

  var _autoValidate = false;
  var _saveNeeded = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    _item = await Budget.of(widget.bookId).get(widget.id);
    if (_item == null) _item = new Budget(widget.bookId, date: new DateTime.now());
    _ctrl = {
      'title': new TextEditingController(text: _item.title ?? ''),
      'value': new TextEditingController(text: _item.value.toString()),
      'spent': new TextEditingController(text: _item.spent.toString()),
      'descr': new TextEditingController(text: _item.descr ?? ''),
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
      await _item.save();
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

  String _validateValue(String value) {
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
        title: new Text(widget.id == null ? lang.titleAddBudget() : lang.titleEditBudget()),
        actions: [
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new SingleChildScrollView(
          child: new Column(children: [
            // -- title --
            new TextFormField(
              initialValue: _ctrl != null ? _ctrl['title'].text : '',
              controller: valueOf(_ctrl, 'title'),
              decoration: new InputDecoration(labelText: lang.lblTitle()),
              onSaved: (String value) => _item.title = value,
              validator: _validateTitle,
              autofocus: widget.id == null,
            ),

            // -- date --
            new DateFormField(
              label: lang.lblDate(),
              date: _item?.date ?? new DateTime.now(),
              onChange: (DateTime value) => _item.date = value,
            ),

            new Row(
              children: [
                // -- value --
                new Expanded(child: new TextFormField(
                  initialValue: _ctrl != null ? _ctrl['value'].text : '',
                  controller: valueOf(_ctrl, 'value'),
                  decoration: new InputDecoration(labelText: lang.lblValue()),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) => _item.value = parseDouble(value),
                  validator: _validateValue,
                )),

                new Container(width: 16.0),

                // -- spent --
                new Expanded(child: new TextFormField(
                  initialValue: _ctrl != null ? _ctrl['spent'].text : '',
                  controller: valueOf(_ctrl, 'spent'),
                  decoration: new InputDecoration(labelText: lang.lblSpent()),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) => _item.spent = parseDouble(value),
                  validator: _validateValue,
                )),
              ],
            ),

            // -- descr --
            new TextFormField(
              initialValue: _ctrl != null ? _ctrl['descr'].text : '',
              controller: valueOf(_ctrl, 'descr'),
              maxLines: 3,
              decoration: new InputDecoration(labelText: lang.lblDescr()),
              onSaved: (String value) => _item.descr = value,
            ),
          ]),
        ),
      ),
    );
  }
}
