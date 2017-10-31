/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceListPage extends StatefulWidget {
  static const kRouteName = '/balances';

  final Config config;
  final String bookId;

  BalanceListPage({
    Key key,
    @required this.config,
    @required this.bookId,
  }) : assert(config != null),
       assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _BalanceListPageState();
}

class _BalanceListPageState extends State<BalanceListPage> {
  final _appBarKey = new GlobalKey<ListAppBarState<Balance>>();
  final _dialogKey = new GlobalKey<BalanceFormState>();
  final List<Balance> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return new Scaffold(
      appBar: new ListAppBar<Balance>(
        key: _appBarKey,
        title: lang.titleBalance(),
        onActionModeTap: (key, items) {
          switch (key) {
            case 'edit':
              _onItemTap(items[0]);
              break;
            case 'delete':
              showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
                if (!ret) return;
                items.forEach((val) => Balance.remove(currentBook.id, val.id));
                _appBarKey.currentState.exitActionMode();
              });
              break;
          }
        },
        onExitActionMode: () => clearSelection(),
      ),
      body: new FirebaseAnimatedList(
        query: Balance.getNode(widget.bookId),
        sort: (a, b) {
          return a.key.compareTo(b.key);
        },
        defaultChild: new Center(child: new Text(Lang.of(context).msgEmptyData())),
        itemBuilder: (context, snapshot, animation, index) {
          final item = new Balance.fromSnapshot(snapshot);
          return new _ContentBalanceItem(
            config: widget.config,
            item: item,
            animation: animation,
            selected: _getSelectedIndex(_selectedItems, item) != -1,
            onTap: () => _onTap(item),
            onLongPress: () => _onLongPress(item),
          );
        }
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, BalancePage.kRouteName),
        child: kIconAdd,
      ),
    );
  }

  void _onItemTap(Balance item) {
    final lang = Lang.of(context);
    final dateFormatter = new DateFormat.yMMMM();
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text(dateFormatter.format(new DateTime(item.year, item.month))),
        content: new BalanceForm(
          key: _dialogKey,
          bookId: widget.bookId,
          item: item,
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _dialogKey.currentState.discard();
              Navigator.pop(context);
            },
            child: new Text(lang.btnCancel().toUpperCase()),
          ),
          new FlatButton(
            onPressed: () {
              _dialogKey.currentState.save();
              Navigator.pop(context);
            },
            child: new Text(lang.btnSave().toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _onTap(Balance item) {
    if (_selectedItems.length > 0) {
      final idx = _getSelectedIndex(_selectedItems, item);
      if (idx >= 0) {
        setState(() => _selectedItems.removeAt(idx));
      } else {
        setState(() => _selectedItems.add(item));
      }
      _onItemsSelect(_selectedItems, idx);
    } else {
      _onItemTap(item);
    }
  }

  void _onLongPress(Balance data) {
    if (_selectedItems.length > 0) return;
    setState(() => _selectedItems.add(data));
    _onItemsSelect(_selectedItems, 0);
  }

  void _onItemsSelect(List<Balance> items, int index) {
    if (items.length == 0)
      _appBarKey.currentState.exitActionMode();
    else
      _appBarKey.currentState.showActionMode(items);
  }

  int _getSelectedIndex(List<Balance> items, Balance item) {
    if (items == null) return -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == item.id) return i;
    }
    return -1;
  }

  void clearSelection() {
    setState(() => _selectedItems.clear());
  }
}

class _ContentBalanceItem extends StatelessWidget {
  final Config config;
  final Balance item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentBalanceItem({
    @required this.config,
    this.item,
    this.animation,
    this.selected,
    this.onTap,
    this.onLongPress,
  }) : assert(config != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);
    final date = new DateTime(item.year, item.month);
    final currFormatter = new NumberFormat.currency(symbol: config.currencySymbol);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          title: new Text(new DateFormat.yMMMM().format(date)),
          subtitle: new Text(currFormatter.format(item.value)),
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
