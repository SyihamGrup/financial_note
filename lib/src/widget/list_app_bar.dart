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

import 'package:financial_note/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListAppBar<T> extends StatefulWidget implements PreferredSizeWidget {
  final Size preferredSize;
  final String title;
  final OnActionTap<List<T>> onActionModeTap;
  final VoidCallback onStartActionMode;
  final VoidCallback onExitActionMode;
  final Color backgroundColor;

  ListAppBar({
    Key key,
    this.title,
    this.onActionModeTap,
    this.onStartActionMode,
    this.onExitActionMode,
    this.backgroundColor,
  }) : preferredSize = new Size.fromHeight(kToolbarHeight),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new ListAppBarState<T>();
}

class ListAppBarState<T> extends State<ListAppBar> {
  var _isActionMode = false;
  var _items = <T>[];

  void showActionMode(List<T> items) {
    if (_isActionMode) return;
    setState(() {
      _isActionMode = true;
      _items = items;
    });
    if (widget.onStartActionMode != null) widget.onStartActionMode();
  }

  void exitActionMode() {
    if (!_isActionMode) return;
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
    return new WillPopScope(
      child: new AppBar(
        backgroundColor: _isActionMode ? kBgActionMode : widget.backgroundColor,
        leading: _isActionMode ? new IconButton(icon: kIconBack, onPressed: () {
          exitActionMode();
        }) : null,
        title: new Text(
          _isActionMode ? _items.length.toString() : widget.title,
        ),
        actions: actions,
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isActionMode) return true;
    exitActionMode();
    return false;
  }
}
