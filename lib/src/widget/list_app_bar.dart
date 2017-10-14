/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListAppBar<T> extends StatefulWidget implements PreferredSizeWidget {
  final Size preferredSize;
  final OnActionTap<List<T>> onActionModeTap;
  final VoidCallback onExitActionMode;

  ListAppBar({Key key, this.onActionModeTap, this.onExitActionMode})
    : preferredSize = new Size.fromHeight(kToolbarHeight),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new ListAppBarState<T>();
}

class ListAppBarState<T> extends State<ListAppBar> {
  var _isActionMode = false;
  var _items = <T>[];

  void showActionMode(List<T> items) {
    setState(() {
      _isActionMode = true;
      _items = items;
    });
  }

  void exitActionMode() {
    setState(() => _isActionMode = false);
    if (widget.onExitActionMode != null) widget.onExitActionMode();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (_isActionMode) {
      if (_items.length == 1) {
        actions.add(new IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            if (widget.onActionModeTap != null) {
              widget.onActionModeTap('edit', _items);
            }
          },
        ));
      }
      actions.add(new IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          if (widget.onActionModeTap != null) {
            widget.onActionModeTap('delete', _items);
          }
        },
      ));
    }
    return new AppBar(
      backgroundColor: _isActionMode ? kBgActionMode : null,
      leading: _isActionMode ? new IconButton(icon: kIconBack, onPressed: () {
        exitActionMode();
      }) : null,
      title: new Text(
        _isActionMode ? _items.length.toString() : Lang.of(context).titleBudget()
      ),
      actions: actions,
    );
  }
}
