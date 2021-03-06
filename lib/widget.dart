/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library widget;

import 'dart:async';

import 'package:financial_note/strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

export 'src/widget/content.dart';
export 'src/widget/date_form_field.dart';
export 'src/widget/dialog.dart';
export 'src/widget/drawer.dart';
export 'src/widget/dropdown.dart';
export 'src/widget/list_app_bar.dart';
export 'src/widget/month_picker.dart';
export 'src/widget/radio.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle style, String url, String text}) : super(
    style: style,
    text: text ?? url,
    recognizer: new TapGestureRecognizer()..onTap = () => launch(url),
  );
}

Future<bool> showConfirmDialog(BuildContext context, Widget content, [Widget title]) {
  final lang = Lang.of(context);
  return showDialog<bool>(
    context: context,
    child: new AlertDialog(
      title: title,
      content: content,
      actions: [
        new FlatButton(
          onPressed: () => Navigator.pop(context, false),
          child: new Text(lang.btnNo().toUpperCase()),
        ),
        new FlatButton(
          onPressed: () => Navigator.pop(context, true),
          child: new Text(lang.btnYes().toUpperCase()),
        ),
      ],
    ),
  );
}

Future<bool> showDeleteConfirmDialog(BuildContext context, [Widget content, Widget title]) async {
  final lang = Lang.of(context);
  if (content == null) content = new Text(lang.msgConfirmDelete());
  if (title == null) title = new Text(lang.titleDelete());
  return await showConfirmDialog(context, content, title);
}

Future<bool> showLeaveConfirmDialog(BuildContext context) async {
  return await showConfirmDialog(
    context,
    new Text(Lang.of(context).msgConfirmLeave()),
    new Text(Lang.of(context).titleLeave()),
  );
}
