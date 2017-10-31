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
import 'package:financial_note/utils.dart';
import 'package:financial_note/widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BalancePage extends StatefulWidget {
  static const kRouteName = '/balance';
  final String bookId;
  final String id;

  BalancePage({Key key, @required this.bookId, this.id})
    : assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final _formKey = new GlobalKey<BalanceFormState>();
  Balance _item;

  @override initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    _item = await Balance.get(widget.bookId, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(icon: kIconClose, onPressed: () {
          _formKey.currentState.discard();
          nav.pop();
        }),
        title: new Text(widget.id == null ? lang.titleAddBalance() : lang.titleEditBalance()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => _formKey.currentState.save().then((saved) {
              if (saved) Navigator.pop(context);
            }),
            child: new Text(lang.btnSave().toUpperCase(), style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: new BalanceForm(key: _formKey, bookId: widget.bookId, item: _item),
    );
  }
}

class BalanceForm extends StatefulWidget {
  final String bookId;
  final Balance item;

  BalanceForm({
    Key key,
    @required this.bookId,
    this.item
  }) : assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new BalanceFormState(item);
}

class BalanceFormState extends State<BalanceForm> {
  final _formKey = new GlobalKey<FormState>();
  final Map<String, TextEditingController> _ctrl;
  final Balance _item;
  var _autoValidate = false;
  var _saveNeeded = true;

  BalanceFormState(Balance item)
    : _item = item ?? new Balance(),
    _ctrl = {
      'value': new TextEditingController(text: item?.value?.toString() ?? ''),
    };

  void discard() {
    _saveNeeded = false;
  }

  Future<bool> save() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      return false;
    }
    form.save();
    try {
      await Balance.setValue(widget.bookId, _item.year, _item.month, _item.value);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;
    final saved = await save();
    if (!saved) return await showLeaveConfirmDialog(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final widgets = <Widget>[];

    if (widget.item == null) {
      final now = new DateTime.now();
      // -- period --
      widgets.add(new MonthFormField(
        label: lang.lblMonth(),
        year: _item.id == null ? now.year : _item.year,
        month: _item.id == null ? now.month : _item.month,
        onChange: (date) {
          _item.year = date.year;
          _item.month = date.month;
        },
      ));
    }

    // -- value --
    widgets.add(new TextFormField(
        initialValue: _ctrl['value'].text,
        controller: _ctrl['value'],
        decoration: new InputDecoration(labelText: lang.lblValue()),
        onSaved: (String value) => _item.value = parseDouble(value),
        validator: _validateValue,
        keyboardType: TextInputType.number,
        autofocus: _item.id == null,
      ),
    );

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: _onWillPop,
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: widgets),
      ),
    );
  }

  String _validateValue(String value) {
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
  }
}
