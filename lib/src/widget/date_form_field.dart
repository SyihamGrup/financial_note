/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class DateFormField extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFormat dateFormat;
  final ValueChanged<DateTime> onChange;

  DateFormField({Key key, this.label, this.date, this.firstDate, this.lastDate,
                 this.dateFormat, @required this.onChange})
    : assert(onChange != null),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: new Text(label,
            style: theme.textTheme.caption.copyWith(color: theme.hintColor)),
        ),
        new Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: new DateItem(date: date, firstDate: firstDate, lastDate: lastDate,
                              dateFormat: dateFormat, onChange: onChange,
                              padding: 6.0),
        ),
      ],
    );
  }
}

class DateItem extends StatelessWidget {
  final DateTime date;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFormat dateFormat;
  final ValueChanged<DateTime> onChange;
  final double padding;

  DateItem({ Key key, DateTime date, this.firstDate, this.lastDate,
             DateFormat dateFormat, @required this.onChange, this.padding: 0.0 })
    : assert(onChange != null),
      this.date = date ?? new DateTime.now(),
      this.dateFormat = dateFormat ?? new DateFormat('EEE, MMM d yyyy'),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return new DefaultTextStyle(
      style: theme.textTheme.subhead,
      child: new Container(
        padding: new EdgeInsets.only(top: padding),
        // Sementara hilangkan border bottom
        /*decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(
            color: theme.disabledColor,
            width: 1.0,
          )),
        ),*/
        child: new InkWell(
          onTap: () {
            showDatePicker(
              context: context,
              initialDate: date,
              firstDate: firstDate ?? date.subtract(const Duration(days: 365 * 5)),
              lastDate: lastDate ?? date.add(const Duration(days: 365 * 5))
            )
            .then<Null>((DateTime value) {
              onChange(new DateTime(value.year, value.month, value.day));
            });
          },
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(dateFormat.format(date)),
              const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 22.0),
            ],
          ),
        ),
      ),
    );
  }
}
