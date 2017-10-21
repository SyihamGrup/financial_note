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

  final String bookId;
  final String groupId;
  final DatabaseReference groupRef;
  final DatabaseReference ref;

  BillPage({Key key, @required this.bookId, this.groupId})
    : assert(bookId != null),
      groupRef = BillGroup.ref(bookId),
      ref = Bill.ref(bookId),
      super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _BillPageState(groupId: groupId);
  }
}

class _BillPageState extends State<BillPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  var _groupCtrl = <String, TextEditingController>{
    'title': new TextEditingController(),
    'note': new TextEditingController(),
  };
  var _ctrls = <Map<String, TextEditingController>>[{
    'title': new TextEditingController(),
    'value': new TextEditingController(),
  }];

  var _group = new BillGroup();
  var _items = <Bill>[new Bill(date: new DateTime.now())];

  var _autoValidate = false;
  var _saveNeeded = true;

  _BillPageState({String groupId}) {
    _group.id = groupId;
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    if (_group.id == null) return;

    final groupSnap = await widget.groupRef.child(_group.id).once();
    if (groupSnap.value == null) return;
    _group = new BillGroup.fromSnapshot(groupSnap);

    _groupCtrl = <String, TextEditingController>{
      'title': new TextEditingController(text: _group.title ?? ''),
      'note': new TextEditingController(text: _group.note ?? ''),
    };

    final snap = await widget.ref.orderByChild('group_id').equalTo(_group.id).once();
    if (snap.value == null) return;
    final Map<String, Map<String, dynamic>> data = snap.value;
    var items = <Bill>[];
    data.forEach((key, value) => items.add(new Bill.fromJson(value)));
    items.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return a.title.compareTo(b.title);
    });
    _items = items;

    final ctrls = <Map<String, TextEditingController>>[];
    _items.forEach((item) {
      ctrls.add(<String, TextEditingController>{
        'title': new TextEditingController(text: item.title ?? ''),
        'value': new TextEditingController(text: item.value.toString()),
      });
    });
    _ctrls = ctrls;
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
    _fillData();

    final groupSnap = _group.id != null ? widget.groupRef.child(_group.id) : widget.groupRef.push();
    await groupSnap.set(_group.toJson());

    final existing = await widget.ref.orderByChild('group_id').equalTo(groupSnap.key).once();
    if (existing.value is Map) {
      existing.value.forEach((key, value) => widget.ref.child(key).remove());
    }
    _items.forEach((item) {
      final snap = widget.ref.push();
      final data = item.toJson();
      data['group_id'] = groupSnap.key;
      snap.set(data);
    });

    _showInSnackBar(Lang.of(context).msgSaved());
    return true;
  }

  void _fillData() {
    _group.startDate = null;
    _group.endDate = null;
    _group.itemsCount = _items.length;
    _group.totalValue = 0.0;
    _group.lastPaid = null;
    _group.paidValue = 0.0;

    _items.forEach((item) {
      if (_group.startDate == null || item.date.isBefore(_group.startDate)) {
        _group.startDate = item.date;
      }
      if (_group.endDate == null || item.date.isAfter(_group.endDate)) {
        _group.endDate = item.date;
      }
      _group.totalValue += item.value;
      if (item.paidDate != null &&
          (_group.lastPaid == null || item.paidDate.isAfter(_group.lastPaid))) {
        _group.lastPaid = item.paidDate;
      }
      _group.paidValue += item.paidValue;
    });
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
      child: new SingleChildScrollView(child: new ListBody(children: [
        // -- title --
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new TextFormField(
            initialValue: _groupCtrl['title'].text,
            controller: _groupCtrl['title'],
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => _group.title = value,
            validator: _validateTitle,
            autofocus: _group.id == null,
          ),
        ),

        // -- bill items --
        _buildFormItems(context),

        // -- note --
        new Column(children: <Widget>[new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new TextFormField(
            initialValue: _groupCtrl['note'].text,
            controller: _groupCtrl['note'],
            maxLines: 3,
            decoration: new InputDecoration(labelText: lang.lblNote()),
            onSaved: (String value) => _group.note = value,
          ),
        )]),
      ]),
    ));
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
                  initialValue: _ctrls[index]['title'].text,
                  controller: _ctrls[index]['title'],
                  decoration: new InputDecoration(labelText: lang.lblItem() + ' ${index + 1}'),
                  onSaved: (String value) => setState(() => item.title = value),
                  validator: _validateTitle,
                ),

                new TextFormField(
                  initialValue: _ctrls[index]['value'].text,
                  controller: _ctrls[index]['value'],
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
                  _ctrls.removeAt(index);
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
          _ctrls.add({
            'title': new TextEditingController(),
            'value': new TextEditingController()
          });
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
