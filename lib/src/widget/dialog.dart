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

import 'package:financial_note/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<String> showInputDialog({
  @required BuildContext context,
  Widget title,
  String label,
  String initialValue,
  keyboardType : TextInputType.text
}) async {
  assert(context != null);
  final _dialogKey = new GlobalKey<_DialogInputFormState>();
  final lang = Lang.of(context);
  String value;

  final dialogRet = await showDialog<bool>(
    context: context,
    child: new AlertDialog(
      title: title,
      content: new DialogInputForm(
        key: _dialogKey,
        label: label,
        initialValue: initialValue,
        keyboardType: keyboardType,
      ),
      actions: [
        new FlatButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: new Text(lang.btnCancel().toUpperCase()),
        ),
        new FlatButton(
          onPressed: () {
            value = _dialogKey.currentState.getValue();
            Navigator.pop(context, true);
          },
          child: new Text(lang.btnSave().toUpperCase()),
        ),
      ],
    ),
  );
  if (dialogRet == null || !dialogRet) return null;
  return value;
}


class DialogInputForm extends StatefulWidget {
  final String initialValue;
  final String label;
  final TextInputType keyboardType;

  DialogInputForm({
    Key key,
    this.label,
    this.initialValue,
    this.keyboardType : TextInputType.text
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DialogInputFormState(initialValue);
}

class _DialogInputFormState extends State<DialogInputForm> {
  final _formKey = new GlobalKey<FormState>();
  final TextEditingController _ctrl;
  String value;

  _DialogInputFormState(String initialValue)
    : _ctrl = new TextEditingController(text: initialValue ?? '');

  String getValue() {
    final form = _formKey.currentState;
    form.save();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new TextFormField(
          initialValue: _ctrl.text,
          controller: _ctrl,
          decoration: new InputDecoration(labelText: widget.label),
          onSaved: (String value) => this.value = value,
          keyboardType: widget.keyboardType,
        ),
      ),
    );
  }
}
