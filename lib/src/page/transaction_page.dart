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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum TransType { income, expense }

class TransactionPage extends StatefulWidget {
  static const kRouteName = '/transaction';

  final String bookId;
  final DatabaseReference ref;
  final TransType transType;

  TransactionPage({Key key, @required this.bookId, this.transType: TransType.expense})
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

  TransType _transType;
  var _trans = new Transaction(title: null, date: null, value: 0.0);

  var _autoValidate = false;
//  var _isCancelled = false;
  var _formWasEdited = false;
  var _saveNeeded = false;

  _TransactionPageState({TransType transType: TransType.expense})
    : _transType = transType;

  //  var person = new PersonData();
//  final _passwordFieldKey = new GlobalKey<FormFieldState<String>>();
//  final _phoneNumberFormatter = new _UsNumberTextInputFormatter();

  @override
  void initState() {
    super.initState();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }

  void _handleSubmitted() {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;  // Start validating on every change
      showInSnackBar(Lang.of(context).msgFormError());
    } else {
      form.save();
      showInSnackBar(Lang.of(context).msgSaved());
    }

//    reference.push().set({
//      'text': text,
//      'imageUrl': imageUrl,
//      'senderName': googleSignIn.currentUser.displayName,
//      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
//    });
  }

  // TODO: Menyimpan data disini
  Future<bool> _warnInvalidData() async {
    final form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return await showDialog<bool>(
      context: context,
      child: new AlertDialog(
        title: new Text(lang.msgFormHasError()),
        content: new Text('confirm leaving?'),
        actions: <Widget> [
          new FlatButton(
            child: new Text(lang.btnYes().toUpperCase()),
            onPressed: () => nav.pop(true),
          ),
          new FlatButton(
            child: new Text(lang.btnNo().toUpperCase()),
            onPressed: () => nav.pop(false),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lang = Lang.of(context);
    final nav = Navigator.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new IconButton(icon: kIconClose, onPressed: () => nav.pop()),
        title: new Text(lang.titleAddTransaction()),
        actions: <Widget>[
          new FlatButton(
            onPressed: _handleSubmitted,
            child: new Text(lang.btnSave().toUpperCase(),
                style: theme.primaryTextTheme.button),
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }

  void _onTransTypeChange(TransType type) {
    _saveNeeded = true;
    setState(() => _transType = type);
  }

  String _validateTitle(String value) {
    _saveNeeded = true;
    if (value.isEmpty) {
      return Lang.of(context).msgFieldRequired();
    }
    return null;
  }

  String _validateValue(String value) {
//    _saveNeeded = true;
//    if (value.isEmpty) {
//      return Lang.of(context).msgFieldRequired();
//    }
    return null;
  }

  Widget _buildForm(BuildContext context) {
    final lang = Lang.of(context);

    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      onWillPop: _warnInvalidData,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new Row(children: <Widget>[
            new Radio(
              value: TransType.income,
              groupValue: _transType,
              onChanged: (TransType value) => _onTransTypeChange(value),
            ),
            new Container(
              child: new GestureDetector(
                child: new Text(lang.lblIncome()),
                onTap: () => _onTransTypeChange(TransType.income),
              ),
              margin: const EdgeInsets.only(right: 8.0),
            ),
            new Radio(
              value: TransType.expense,
              groupValue: _transType,
              onChanged: (TransType value) => _onTransTypeChange(value),
            ),
            new GestureDetector(
              child: new Text(lang.lblExpense()),
              onTap: () => _onTransTypeChange(TransType.expense),
            ),
          ]),

          new InputDecorator(
            decoration: new InputDecoration(labelText: lang.lblBudget()),
            isEmpty: _trans.budgetId == null,
            child: new DropdownButtonHideUnderline(child: new DropdownButton<String>(
              value: _trans.budgetId,
              isDense: true,
              onChanged: (String newValue) {
                setState(() => _trans.budgetId = newValue == '' ? null : newValue);
              },
              items: <DropdownMenuItem<String>>[
                new DropdownMenuItem<String>(value: '', child: new Text('None')),
                new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
                new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
                new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
                new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
              ],
            )),
          ),

          new Row(children: <Widget>[
            new Expanded(child: new InputDecorator(
              decoration: new InputDecoration(labelText: lang.lblBill()),
              isEmpty: _trans.billId == null,
              child: new DropdownButtonHideUnderline(child: new DropdownButton<String>(
                value: _trans.billId,
                isDense: true,
                onChanged: (String newValue) {
                  setState(() => _trans.billId = newValue == '' ? null : newValue);
                },
                items: <DropdownMenuItem<String>>[
                  new DropdownMenuItem<String>(value: '', child: new Text('None')),
                  new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
                  new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
                  new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
                  new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
                ],
              )),
            )),

            new Container(width: 8.0),

            new Expanded(child: new InputDecorator(
              decoration: new InputDecoration(labelText: lang.lblBillPeriod()),
              isEmpty: _trans.billId == null,
              child: new DropdownButtonHideUnderline(child: new DropdownButton<String>(
                value: _trans.billId,
                isDense: true,
                onChanged: (String newValue) {
                  setState(() => _trans.billId = newValue == '' ? null : newValue);
                },
                items: <DropdownMenuItem<String>>[
                  new DropdownMenuItem<String>(value: '', child: new Text('None')),
                  new DropdownMenuItem<String>(value: '1', child: new Text('Hiking')),
                  new DropdownMenuItem<String>(value: '2', child: new Text('Swimming')),
                  new DropdownMenuItem<String>(value: '3', child: new Text('Boating')),
                  new DropdownMenuItem<String>(value: '4', child: new Text('Fishing')),
                ],
              )),
            )),
          ]),

          new TextFormField(
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => setState(() => _trans.title = value),
            validator: _validateTitle,
          ),

          new TextFormField(
            controller: new TextEditingController(text: '0'),
            decoration: new InputDecoration(labelText: lang.lblValue()),
            keyboardType: TextInputType.number,
            onSaved: (String value) => setState(() => _trans.value = double.parse(value)),
            validator: _validateValue,
          ),
        ],
      ),
    );
  }

}
