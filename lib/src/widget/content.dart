import 'package:financial_note/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

class ContentHighlight extends StatelessWidget {
  final Config config;
  final Widget child;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  const ContentHighlight({
    @required
    this.config,
    this.alignment,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = config.themeName == ThemeName.dark
                  ? Colors.grey[800] : Colors.blueGrey[100];
    return new Container(
      decoration: new BoxDecoration(
        color: bgColor,
        boxShadow: <BoxShadow>[
          const BoxShadow(color: const Color(0x88000000), blurRadius: 2.0)
        ],
      ),
      alignment: alignment,
      padding: padding,
      child: child,
    );
  }
}
