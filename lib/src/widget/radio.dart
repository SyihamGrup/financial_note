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

class RadioGroup<T> extends StatelessWidget {

  final List<RadioItem<T>> items;
  final ValueChanged<T> onChanged;
  final T groupValue;
  final Axis direction;

  RadioGroup({@required this.items, this.groupValue, this.onChanged,
              this.direction: Axis.horizontal})
    : assert(items != null && items.length > 1);

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    items.forEach((item) {
      widgets.add(new Row(children: <Widget>[
        new Radio(
          value: item.value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        new Container(
          child: new GestureDetector(
            child: new Text(item.label),
            onTap: onChanged != null ? () => onChanged(item.value) : null,
          ),
          margin: const EdgeInsets.only(right: 8.0),
        ),
      ]));
    });
    return new DefaultTextStyle(
      style: Theme.of(context).textTheme.subhead,
        child: new Flex(
        direction: direction,
        children: widgets,
      ),
    );
  }
}

class RadioItem<T> {
  String label;
  T value;

  RadioItem(this.value, this.label)
    : assert(value != null), assert(label != null);
}
