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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TransactionPage extends StatefulWidget {
  static const kRouteName = '/transaction';

  final String bookId;
  final String id;
  final int transType;
  final DatabaseReference ref;

  TransactionPage({Key key, @required this.bookId, this.id, this.transType: kExpense})
    : assert(bookId != null),
      ref = Transaction.ref(bookId),
      super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _TransactionPageState(transType: this.transType);
  }
}

class _TransactionPageState extends State<TransactionPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  var _item = new Transaction(date: new DateTime.now());
  var _ctrl = <String, TextEditingController>{
    'title': new TextEditingController(),
    'value': new TextEditingController(),
  };
  var _budgets = <Budget>[];
  var _billsGroup = <BillGroup>[];
  var _bills = <Bill>[];

  int _transType;

  var _autoValidate = false;
  var _saveNeeded = false;

  _TransactionPageState({int transType: kExpense})
    : _transType = transType;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    if (_item.id == null) return;

    final snap = await widget.ref.child(_item.id).once();
    if (snap.value == null) return;
    _item = new Transaction.fromSnapshot(snap);
    _ctrl = <String, TextEditingController>{
      'title': new TextEditingController(text: _item.title ?? ''),
      'value': new TextEditingController(text: _item.value.toString()),
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

    form.save();
    try {
      final ref = _item.id != null ? widget.ref.child(_item.id)
                                   : widget.ref.push();
      ref.set(_item.toJson());
      return true;
    } catch (e) {
      _showInSnackBar(e.message);
      return false;
    }
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
        title: new Text(_item.id == null ? lang.titleAddTransaction()
                                         : lang.titleEditTransaction()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => _handleSubmitted().then((saved) {
              if (saved) Navigator.pop(context);
            }),
            child: new Text(lang.btnSave().toUpperCase(),
                            style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);

    final budgetItems = <DropdownMenuItem<String>>[
      new DropdownMenuItem<String>(value: '', child: new Text('None')),
      new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
      new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
      new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
      new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
    ];

    final groupItems = <DropdownMenuItem<String>>[
      new DropdownMenuItem<String>(value: '', child: new Text('None')),
      new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
      new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
      new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
      new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
    ];

    final billItems = <DropdownMenuItem<String>>[
      new DropdownMenuItem<String>(value: '', child: new Text('None')),
      new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
      new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
      new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
      new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
    ];

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: _onWillPop,
      child: new ListView(
        children: <Widget>[
          // -- transType --
          new Container(
            decoration: new BoxDecoration(color: theme.highlightColor),
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 32.0),
            child: new RadioGroup(
              groupValue: _transType,
              items: <RadioItem<int>>[
                new RadioItem<int>(kIncome, lang.lblIncome()),
                new RadioItem<int>(kExpense, lang.lblExpense()),
              ],
              onChanged: (value) => setState(() => _transType = value),
            ),
          ),

          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: new Column(children: <Widget>[
              new Column(children: <Widget>[
                // -- budgetId --
                new DropdownFormField<String>(
                  label: lang.lblBudget(),
                  value: _item.budgetId,
                  items: budgetItems,
                  onChanged: (value) {
                    setState(() => _item.budgetId = value == '' ? null : value);
                  },
                ),

                new Row(children: <Widget>[
                  // -- groupId --
                  new Expanded(child: new DropdownFormField<String>(
                    label: lang.lblBill(),
                    value: _item.billId,
                    items: groupItems,
                    onChanged: (value) {
                      setState(() => _item.billId = value == '' ? null : value);
                    },
                  )),

                  new Padding(padding: const EdgeInsets.only(left: 16.0)),

                  // -- billId --
                  new Expanded(child: new DropdownFormField<String>(
                    label: lang.lblBillPeriod(),
                    value: _item.billId,
                    items: billItems,
                    onChanged: (value) {
                      setState(() => _item.billId = value == '' ? null : value);
                    },
                  )),
                ]),

                // -- title --
                new TextFormField(
                  initialValue: _ctrl['title'].text,
                  controller: _ctrl['title'],
                  decoration: new InputDecoration(labelText: lang.lblTitle()),
                  onSaved: (String value) => _item.title = value,
                  validator: _validateTitle,
                ),

                // -- value --
                new TextFormField(
                  initialValue: _ctrl['value'].text,
                  controller: _ctrl['value'],
                  decoration: new InputDecoration(labelText: lang.lblValue()),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) => _item.value = parseDouble(value),
                  validator: _validateValue,
                ),
              ]),
            ]),
          ),
        ],
      ),
    );

  }

}
