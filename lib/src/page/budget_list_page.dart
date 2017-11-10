/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page_budget_list;

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/utils.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'home_page_budget.dart';

class BudgetListPage extends StatefulWidget {
  static const kRouteName = '/home-budgets';

  final Config config;
  final String bookId;
  final OnItemTap<Budget> onItemTap;
  final OnItemSelect<Budget> onItemsSelect;

  BudgetListPage({
    Key key,
    @required this.config,
    @required this.bookId,
    this.onItemTap,
    this.onItemsSelect,
  }) : assert(config != null),
       assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> with SelectableList<Budget> {
  List<Budget> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
      query: getNode(Budget.kNodeName, widget.bookId),
      sort: (a, b) {
        final aDate = a.value is Map && a.value.containsKey('date') ? a.value['date'] : '';
        final bDate = b.value is Map && b.value.containsKey('date') ? b.value['date'] : '';
        return bDate.compareTo(aDate);
      },
      defaultChild: const EmptyBody(),
      itemBuilder: (context, snapshot, animation, index) {
        final item = new Budget.fromSnapshot(widget.bookId, snapshot);
        return new _ContentBudgetItem(
          config: widget.config,
          item: item,
          animation: animation,
          selected: getSelectedIndex(item) != -1,
          currencySymbol: widget.config?.currencySymbol,
          onTap: () => onListTap(item),
          onLongPress: () => onListLongPress(item),
        );
      }
    );
  }

  @override
  int getSelectedIndex(Budget item) {
    if (_selectedItems == null) return -1;
    for (int i = 0; i < _selectedItems.length; i++) {
      if (_selectedItems[i].id == item.id) return i;
    }
    return -1;
  }

  @override
  void onSelectionChange(List<Budget> items, int index) {
    setState(() => _selectedItems = items);
    if (widget.onItemsSelect != null) widget.onItemsSelect(items, index);
  }

  @override
  void onItemTap(Budget item) {
    if (widget.onItemTap != null) widget.onItemTap(item);
  }
}

class _ContentBudgetItem extends StatelessWidget {
  final Config config;
  final String currencySymbol;
  final Budget item;
  final Animation animation;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  _ContentBudgetItem({
    @required this.config,
    @required this.item,
    this.animation,
    this.selected,
    this.onTap,
    this.onLongPress,
    this.currencySymbol,
  }) : assert(config != null), assert(item != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);

    final value = item.value ?? 0;
    final spent = item.spent ?? 0;

    final percentColor = theme.brightness == Brightness.dark
                       ? theme.accentColor : theme.primaryColor;
    final percentBg = theme.highlightColor;

    final dateFormatter = new DateFormat.MMMd();
    final date = item.date != null ? dateFormatter.format(item.date) : '';
    final dateStyle = theme.textTheme.body1.copyWith(fontSize: 12.0);
    final percent = value == 0 ? 0 : (spent / value > 1 ? 1 : spent / value);

    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        decoration: selected ? selectedBg : null,
        child: new ListTile(
          leading: new Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 40.0,
                width: 26.0,
                decoration: new BoxDecoration(color: percentBg, border: new Border.all(color: percentColor)),
              ),
              new Container(
                margin: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                width: 20.0,
                height: value > 0 ? 36.0 * percent : 0.0,
                decoration: new BoxDecoration(color: percentColor),
              ),
            ]
          ),
          title: new Text(item.title,
            style: config.getTitleStyle(context, selected: selected),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                lang.lblTotal() + ':' +
                (spent > 0 ? '\n' + lang.lblSpent() + ':' : '')
              ),
              new Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: new Text(
                  formatCurrency(value, symbol: currencySymbol) +
                  (spent > 0 ? '\n' + formatCurrency(spent, symbol: currencySymbol) : ''),
                ),
              ),
            ],
          ),
          trailing: new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 20.0),
            child: new Text(date, style: dateStyle),
          ),
          selected: selected,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
