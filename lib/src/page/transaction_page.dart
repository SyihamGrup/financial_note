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

class TransactionPage extends StatefulWidget {
  static const kRouteName = '/transaction';

  final Config config;
  final String bookId;
  final String id;
  final int transType;

  TransactionPage({
    Key key,
    @required this.config,
    @required this.bookId,
    this.id,
    this.transType: kExpense,
  }) : assert(config != null),
       assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _TransactionPageState(transType: this.transType);
  }
}

class _TransactionPageState extends State<TransactionPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  Transaction _item;
  Map<String, TextEditingController> _ctrl;
  List<Budget> _budgets;
  List<BillGroup> _billsGroup;
  List<Bill> _bills;

  int _transType;
  String _billGroupId;

  var _autoValidate = false;
  var _saveNeeded = false;

  _TransactionPageState({int transType: kExpense}) : _transType = transType;

  @override
  void initState() {
    super.initState();
    _initData();
    _initBudgets();
    _initBills();
  }

  Future<Null> _initData() async {
    _item = await Transaction.get(widget.bookId, widget.id);
    if (_item != null) {
      _transType = _item.value > 0 ? kIncome : kExpense;
      _item.value = _item.value.abs();
    } else {
      _item = new Transaction(date: new DateTime.now());
    }

    _ctrl = <String, TextEditingController>{
      'title': new TextEditingController(text: _item.title ?? ''),
      'value': new TextEditingController(text: _item.value.toString()),
    };
  }

  Future<Null> _initBudgets() async {
    _budgets = await Budget.list(widget.bookId);
  }

  Future<Null> _initBills() async {
    _billsGroup = await BillGroup.list(widget.bookId);

    if (_item.billId != null) {
      final bill = await Bill.get(widget.bookId, _item.billId);
      if (bill != null) _billGroupId = bill.groupId;
    }
    if (_billsGroup == null && _billsGroup.length > 0) {
      _billGroupId = _billsGroup[0].id;
    }
    if (_billGroupId != null) {
      _bills = await BillGroup.getItems(widget.bookId, _billGroupId);
    }
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
      _item.value = _item.value * _transType;
      await _item.save(widget.bookId);
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
        title: new Text(widget.id == null ? lang.titleAddTransaction()
                                          : lang.titleEditTransaction()),
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
          // -- transType --
          new ContentHighlight(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 32.0),
            child: new RadioGroup(
              groupValue: _transType,
              items: <RadioItem<int>>[
                new RadioItem<int>(kIncome, lang.lblIncome()),
                new RadioItem<int>(kExpense, lang.lblExpense()),
              ],
              onChanged: (value) => setState(() => _transType = value),
            )
          ),

          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: new Column(children: <Widget>[
              // -- title --
              new TextFormField(
                initialValue: _ctrl != null ? _ctrl['title'].text : '',
                controller: mapValue(_ctrl, 'title'),
                decoration: new InputDecoration(labelText: lang.lblTitle()),
                onSaved: (String value) => _item.title = value,
                validator: _validateTitle,
              ),

              // -- date --
              new DateFormField(
                label: lang.lblDate(),
                date: _item?.date ?? new DateTime.now(),
                onChange: (DateTime value) => _item.date = value,
              ),

              new Column(children: <Widget>[
                // -- budgetId --
                _buildBudgetDropdown(context),

                new Row(children: <Widget>[
                  // -- groupId --
                  new Expanded(child: _buildGroupDropdown(context)),
                  new Padding(padding: const EdgeInsets.only(left: 16.0)),
                  // -- billId --
                  new Expanded(child: _buildBillDropdown(context)),
                ]),

                // -- value --
                new TextFormField(
                  initialValue: _ctrl != null ? _ctrl['value'].text : '',
                  controller: mapValue(_ctrl, 'value'),
                  decoration: new InputDecoration(labelText: lang.lblValue()),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) => _item.value = parseDouble(value),
                  validator: _validateValue,
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildBudgetDropdown(BuildContext context) {
    final lang = Lang.of(context);
    final items = <DropdownMenuItem<String>>[
      new DropdownMenuItem<String>(value: '', child: new Text(lang.lblNone())),
    ];
    if (_budgets != null) {
      for (final item in _budgets) {
        items.add(new DropdownMenuItem<String>(
          value: item.id,
          child: new Text(item.title, overflow: TextOverflow.ellipsis),
        ));
      }
    }

    return new DropdownFormField<String>(
      label: lang.lblBudget(),
      value: _item?.budgetId,
      items: items,
      onChanged: (value) {
        setState(() => _item.budgetId = value == '' ? null : value);
      },
    );
  }

  Widget _buildGroupDropdown(BuildContext context) {
    final lang = Lang.of(context);
    final items = <DropdownMenuItem<String>>[
      new DropdownMenuItem<String>(value: '', child: new Text(lang.lblNone())),
    ];
    if (_billsGroup != null) {
      for (final item in _billsGroup) {
        items.add(new DropdownMenuItem<String>(
          value: item.id,
          child: new Text(item.title, overflow: TextOverflow.ellipsis),
        ));
      }
    }

    return new DropdownFormField<String>(
      label: lang.lblBill(),
      value: _billGroupId,
      items: items,
      onChanged: (value) {
        setState(() => _billGroupId = value == '' ? null : value);

        if (_billGroupId == null) {
          setState(() {
            _item.billId = null;
            _bills = <Bill>[];
          });
          return;
        }
        BillGroup.getItems(widget.bookId, _billGroupId).then((items) {
          setState(() {
            _bills = items;
            if (_bills != null && _bills.length > 0) {
              _item.billId = _bills[0].id;
              _ctrl['value'].text = _bills[0].value.toString();
            } else {
              _item.billId = null;
            }
          });
        });
      },
    );
  }

  Widget _buildBillDropdown(BuildContext context) {
    final lang = Lang.of(context);
    final items = <DropdownMenuItem<String>>[];
    if (_bills != null && _bills.length > 0) {
      for (final item in _bills) {
        items.add(new DropdownMenuItem<String>(
          value: item.id,
          child: new Text(item.title, overflow: TextOverflow.ellipsis),
        ));
      }
    } else {
      items.add(new DropdownMenuItem<String>(value: '', child: new Text(lang.lblNone())));
    }

    return new DropdownFormField<String>(
      label: lang.lblBillPeriod(),
      value: _item?.billId,
      items: items,
      onChanged: (value) {
        setState(() => _item.billId = value == '' ? null : value);
        final bill = _getBill(_item.billId);
        if (bill != null) {
          _ctrl['value'].text = bill.value.toString();
        }
      },
    );
  }

  Bill _getBill(String id) {
    if (id == null) return null;
    for (final bill in _bills) {
      if (bill.id == id) return bill;
    }
    return null;
  }
}
