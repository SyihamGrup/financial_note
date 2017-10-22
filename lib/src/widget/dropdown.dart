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

class DropdownFormField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  DropdownFormField({
    @required this.label,
    @required this.value,
    this.items,
    this.onChanged,
  }) : assert(label != null),
       assert(items != null);

  @override
  Widget build(BuildContext context) {
    return new InputDecorator(
      decoration: new InputDecoration(labelText: label),
      isEmpty: value == null,
      child: new DropdownButtonHideUnderline(child: new DropdownButton<T>(
        value: value,
        isDense: true,
        items: items,
        onChanged: onChanged,
      )),
    );
  }
}
