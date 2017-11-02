/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/strings.dart';
import 'package:flutter/material.dart';

class EmptyBody extends StatelessWidget {
  final isLoading;

  const EmptyBody({this.isLoading: false});

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Center(child: new Text(
        isLoading ? lang.msgLoading() : lang.msgEmptyData())
      ),
    );
  }
}

class ContentHighlight extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  const ContentHighlight({
    this.alignment,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.dark
                  ? Colors.grey[800] : Colors.blueGrey[100];
    return new Container(
      decoration: new BoxDecoration(
        color: bgColor,
        boxShadow: <BoxShadow>[
          const BoxShadow(color: const Color(0xaa000000), blurRadius: 1.0)
        ],
      ),
      alignment: alignment,
      padding: padding,
      child: child,
    );
  }
}
