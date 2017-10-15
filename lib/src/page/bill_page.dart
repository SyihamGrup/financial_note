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
import 'package:intl/intl.dart';

class BillPage extends StatefulWidget {
  static const kRouteName = '/bill';

  final BillGroup _group;
  final List<Bill> _items;
  final String bookId;
  final DatabaseReference groupRef;
  final DatabaseReference ref;

  BillPage({Key key, @required this.bookId, BillGroup group, List<Bill> items})
    : assert(bookId != null),
      this._group = group ?? new BillGroup(dueDate: new DateTime.now()),
      this._items = items ?? <Bill>[],
      groupRef = BillGroup.ref(bookId),
      ref = Bill.ref(bookId),
      super(key: key) {
    while (_items.length < 1) {
      _items.add(new Bill(title: _items.length.toString(), date: new DateTime.now()));
    }
  }

  @override
  State<StatefulWidget> createState() {
    return new _BillPageState(_group, _items);
  }
}

class _BillPageState extends State<BillPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _titleCtrls = new List<TextEditingController>();
  final _valueCtrls = new List<TextEditingController>();

  final BillGroup _group;
  final List<Bill> _items;

  var _autoValidate = false;
  var _saveNeeded = true;

  _BillPageState(this._group, this._items)
    : assert(_group != null),
      assert(_items != null && _items.length > 0) {
    _items.forEach((item) {
      _titleCtrls.add(new TextEditingController(text: item.title ?? ''));
      _valueCtrls.add(new TextEditingController(text: item.value?.toString() ?? ''));
    });
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
//    final newItem = _items.id != null ? widget.ref.child(_items.id) : widget.ref.push();
//    newItem.set(_items.toJson());

    _showInSnackBar(Lang.of(context).msgSaved());
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
        title: new Text(_group.id == null ? lang.titleAddBill() : lang.titleEditBill()),
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
      child: new ListView(children: <Widget>[
        // -- title --
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new TextFormField(
            initialValue: _group.title ?? '',
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => _group.title = value,
            validator: _validateTitle,
            autofocus: true,
          )
        ),

        const Divider(),

        // -- bill items --
        _buildFormItems(context),

        const Divider(),

        // -- note --
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new TextFormField(
            initialValue: _group.note ?? '',
            maxLines: 3,
            decoration: new InputDecoration(labelText: lang.lblNote()),
            onSaved: (String value) => _group.note = value,
          ),
        ),
      ]),
    );
  }

  Widget _buildFormItems(BuildContext context) {
    final lang = Lang.of(context);

    final widgets = <Widget>[];
    _items.forEach((item) {
      final index = _items.indexOf(item);

      widgets.add(new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // -- date --
          new Container(
            margin: const EdgeInsets.only(left: 16.0),
            width: 110.0,
            child: new DateFormField(
              label: lang.lblDate(),
              date: item.date,
              dateFormat: new DateFormat.yMd(),
              onChange: (DateTime value) => item.date = value,
            )
          ),

          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: new Column(children: <Widget>[
                // -- title --
                new TextFormField(
                  controller: _titleCtrls[index],
                  decoration: new InputDecoration(labelText: lang.lblItem() + ' ${index + 1}'),
                  onSaved: (String value) => setState(() => item.title = value),
                  validator: _validateTitle,
                ),

                new TextFormField(
                  controller: _valueCtrls[index],
                  decoration: new InputDecoration(labelText: lang.lblValue()),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) => setState(() => item.value = parseDouble(value)),
                  validator: _validateValue,
                ),
              ]
            ),
          )
        ),

        // -- action --
        new Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: new Column(
            children: <Widget>[
              new IconButton(
                icon: kIconClose,
                iconSize: 20.0,
                onPressed: _items.length > 1 ? () {
                  _titleCtrls.removeAt(index);
                  _valueCtrls.removeAt(index);
                  setState(() => _items.remove(item));
                } : null
              ),
            ],
          ),
        ),
      ]));
    });

    // -- add item --
    widgets.add(new Padding(
      padding: const EdgeInsets.fromLTRB(136.0, 8.0, 46.0, 16.0),
      child: new FlatButton(
        color: Theme.of(context).buttonColor,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            kIconAdd,
            new Text(lang.btnAddItem().toUpperCase()),
          ],
        ),
        onPressed: () {
          _titleCtrls.add(new TextEditingController());
          _valueCtrls.add(new TextEditingController());
          setState(() => _items.add(new Bill(date: new DateTime.now())));
        },
      ),
    ));

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

}
