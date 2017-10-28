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
import 'package:intl/intl.dart';

class BillPage extends StatefulWidget {
  static const kRouteName = '/bill';

  final String bookId;
  final String groupId;

  BillPage({Key key, @required this.bookId, this.groupId})
    : assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  BillGroup _group;
  List<Bill> _items;
  Map<String, TextEditingController> _groupCtrl;
  List<Map<String, TextEditingController>> _ctrls;

  var _autoValidate = false;
  var _saveNeeded = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<Null> _initData() async {
    _group = await BillGroup.get(widget.bookId, widget.groupId);
    if (_group == null) _group = new BillGroup();
    _groupCtrl = <String, TextEditingController>{
      'title': new TextEditingController(text: _group.title ?? ''),
      'note': new TextEditingController(text: _group.note ?? ''),
    };

    _items = await BillGroup.getItems(widget.bookId, _group.id);
    if (_items == null || _items.length == 0) {
      _items = <Bill>[new Bill(date: new DateTime.now())];
    }
    _ctrls = <Map<String, TextEditingController>>[];
    _items.forEach((item) {
      _ctrls.add(<String, TextEditingController>{
        'title': new TextEditingController(text: item.title ?? ''),
        'value': new TextEditingController(text: item.value.toString()),
      });
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
    _fillData();

    try {
      await _group.save(widget.bookId);
      await _group.saveItems(widget.bookId, _items);
      return true;
    } catch (e) {
      _showInSnackBar(e.message);
      return false;
    }
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
        title: new Text(widget.groupId == null ? lang.titleAddBill() : lang.titleEditBill()),
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
      child: new ListView(children: [
        // -- title --
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new TextFormField(
            initialValue: _groupCtrl != null ? _groupCtrl['title'].text : '',
            controller: mapValue(_groupCtrl, 'title'),
            decoration: new InputDecoration(labelText: lang.lblTitle()),
            onSaved: (String value) => _group.title = value,
            validator: _validateTitle,
            autofocus: widget.groupId == null,
          ),
        ),

        new RadioGroup<int>(
          items: <RadioItem<int>>[
            new RadioItem(kIncome, lang.lblIncome()),
            new RadioItem(kExpense, lang.lblExpense()),
          ],
          groupValue: _group?.transType,
          onChanged: (value) => setState(() => _group.transType = value),
        ),

        // -- bill items --
        _buildFormItems(context),

        // -- note --
        new Column(children: <Widget>[new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new TextFormField(
            initialValue: _groupCtrl != null ? _groupCtrl['note'].text : '',
            controller: _groupCtrl != null ? _groupCtrl['note'] : null,
            maxLines: 3,
            decoration: new InputDecoration(labelText: lang.lblNote()),
            onSaved: (String value) => _group.note = value,
          ),
        )]),
      ]),
    );
  }

  Widget _buildFormItems(BuildContext context) {
    if (_items == null) return new Container();

    final lang = Lang.of(context);
    final widgets = <Widget>[];
    for (final item in _items) {
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
              date: item.date ?? new DateTime.now(),
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
    }

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
