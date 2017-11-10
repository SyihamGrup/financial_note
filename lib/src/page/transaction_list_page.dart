/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page_transaction_list;

import 'dart:async';

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/utils.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'home_page_transaction.dart';

class TransactionListPage extends StatefulWidget {
  static const kRouteName = '/home-transactions';

  final Config config;
  final String bookId;
  final DateTime date;

  final OnItemTap<Transaction> onItemTap;
  final OnItemSelect<Transaction> onItemsSelect;

  const TransactionListPage({
    Key key,
    @required this.config,
    @required this.bookId,
    this.date,
    this.onItemTap,
    this.onItemsSelect,
  }) : assert(config != null),
       assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _TransactionListPageState(date);
}

class _TransactionListPageState extends State<TransactionListPage>
    with SingleTickerProviderStateMixin, SelectableList<Transaction> {
  List<Transaction> _selectedItems = [];
  var _isLoading = true;
  DateTime _filterDate;

  AnimationController _animationCtrl;
  Animation<double> _animation;

  List<Transaction> _items;
  StreamSubscription<Event> _dataSubscr;

  _TransactionListPageState(DateTime date) : _filterDate = date;

  @override
  void initState() {
    super.initState();

    _initProgress();

    _dataSubscr = getNode(Transaction.kNodeName, widget.bookId)
                  .onValue.listen((event) {
      _refreshData(widget.bookId);
    });
  }

  void _initProgress() {
    _animationCtrl =  new AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _animation = new CurvedAnimation(
      parent: _animationCtrl,
      curve: const Interval(0.0, 0.9, curve: Curves.fastOutSlowIn),
      reverseCurve: Curves.fastOutSlowIn
    );
  }

  Future<Null> _refreshData(String bookId) async {
    setState(() => _isLoading = true);
    final dateOpening = new DateTime(_filterDate.year, _filterDate.month, 0);
    final dateStart = new DateTime(_filterDate.year, _filterDate.month);
    final dateEnd = new DateTime(_filterDate.year, _filterDate.month + 1, 0);
    final openingBalance = await Balance.of(bookId).getValue(
      dateOpening.year, dateOpening.month
    );
    final items = await Transaction.of(bookId).list(dateStart, dateEnd, openingBalance);

    items.add(new Transaction(
      bookId,
      title: Lang.of(context).titleOpeningBalance(),
      balance: openingBalance
    ));

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(children: <Widget>[
      _buildBody(context),
      buildListProgress(_animation, isLoading: _isLoading),
    ]);
  }

  Widget _buildBody(BuildContext context) {
    if (_items == null || _items.length == 0)
      return new EmptyBody(isLoading: _isLoading);

    return new Column(children: <Widget>[
      _buildBalance(),
      new Expanded(child: new ListView.builder(
        padding: const EdgeInsets.only(bottom: 72.0),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          if (_items.length <= 1) {
            return new EmptyBody();
          } else if (index == _items.length - 1) {
            return _buildOpeningBalance(item);
          } else {
            return new _ContentTransactionItem(
              context: context,
              config: widget.config,
              item: item,
              selected: getSelectedIndex(item) != -1,
              onTap: () => onListTap(item),
              onLongPress: () => onListLongPress(item),
            );
          }
        },
      )),
    ]);
  }

  Widget _buildBalance() {
    final theme = Theme.of(context);
    final lang = Lang.of(context);
    final balance = _items.length > 0 ? _items[0].balance : 0.0;
    return new ContentHighlight(child: new ListTile(
      dense: true,
      title: new Center(child: new Text(
        lang.titleBalance().toUpperCase(),
        style: theme.textTheme.caption,
      )),
      subtitle: new Center(child: new Text(
        formatCurrency(balance, symbol: widget.config.currencySymbol),
        style: theme.textTheme.title,
      )),
    ));
  }

  Widget _buildOpeningBalance(Transaction item) {
    final textTheme = Theme.of(context).textTheme;
    final lang = Lang.of(context);

    return new ListTile(
      title: new Center(child: new Text(
        lang.titleOpeningBalance().toUpperCase(),
        style: textTheme.caption.copyWith(fontSize: 12.0),
      )),
      subtitle: new Center(child: new Text(
        formatCurrency(item.balance, symbol: widget.config.currencySymbol),
        style: textTheme.title.copyWith(fontSize: 20.0),
      )),
    );
  }


  @override
  int getSelectedIndex(Transaction item) {
    if (_selectedItems == null) return -1;
    for (int i = 0; i < _selectedItems.length; i++) {
      if (_selectedItems[i].id == item.id) return i;
    }
    return -1;
  }

  @override
  void onSelectionChange(List<Transaction> items, int index) {
    setState(() => _selectedItems = items);
    if (widget.onItemsSelect != null) widget.onItemsSelect(items, index);
  }

  @override
  void onItemTap(Transaction item) {
    if (widget.onItemTap != null) widget.onItemTap(item);
  }

  void setDate(DateTime date) {
    setState(() => _filterDate = date);
    _refreshData(widget.bookId);
  }

  void clearSelection() {
    setState(() => _selectedItems.clear());
  }

  @override
  void dispose() {
    if (_animationCtrl != null) _animationCtrl.dispose();
    if (_dataSubscr != null) _dataSubscr.cancel();
    super.dispose();
  }
}

class _ContentTransactionItem extends StatelessWidget {
  final BuildContext context;
  final Config config;
  final Transaction item;

  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  const _ContentTransactionItem({
    @required this.context,
    @required this.config,
    @required this.item,
    this.selected,
    this.onTap,
    this.onLongPress,
  }) : assert(context != null),
       assert(item != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final lang = Lang.of(context);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);
    final valueColor1 = theme.brightness == Brightness.dark
                      ? Colors.green[100] : Colors.green[700];
    final valueColor2 = theme.brightness == Brightness.dark
                      ? Colors.red[100] : Colors.red[700];

    final subtitles = <Widget>[
      new Text((item.value >= 0 ? '+' : '') +
               formatCurrency(item.value, symbol: config.currencySymbol),
        style: textTheme.body2.copyWith(
          color: item.value >= 0 ? valueColor1 : valueColor2,
          fontWeight: FontWeight.normal,
        ),
      )
    ];
    if (item.budgetId != null) subtitles.add(_buildBadge(lang.lblBudget()));
    if (item.billId != null) subtitles.add(_buildBadge(lang.lblBill()));

    return new Container(
      decoration: selected ? selectedBg : null,
      child: new ListTile(
        dense: true,
        leading: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(new DateFormat.MMM().format(item.date),
              style: textTheme.caption
            ),
            new Text(new DateFormat.d().format(item.date),
              style: textTheme.headline
            ),
          ],
        ),
        title: new Text(
          item.title ?? '',
          style: theme.textTheme.subhead,
        ),
        subtitle: new Row(children: subtitles),
        trailing: new Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(top: 14.0),
          child: new Text(
            formatCurrency(item.balance, symbol: config.currencySymbol),
            style: textTheme.subhead,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _buildBadge(String label) {
    final theme = Theme.of(context);
    return new Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: new Container(
        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
        decoration: new BoxDecoration(
          color: theme.highlightColor,
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: new Text(label,
          style: theme.textTheme.caption.copyWith(fontSize: 11.0),
        ),
      ),
    );
  }
}

class TransactionAppBar extends StatefulWidget implements PreferredSizeWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChange;
  final Size preferredSize;

  final OnActionTap<List<Transaction>> onActionModeTap;
  final VoidCallback onExitActionMode;

  TransactionAppBar({
    Key key, DateTime initialDate, this.onDateChange, this.onActionModeTap,
    this.onExitActionMode
  }) : this.initialDate = initialDate ?? new DateTime.now(),
      preferredSize = new Size.fromHeight(kToolbarHeight),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _TransactionAppBarState(initialDate);
}

class _TransactionAppBarState extends State<TransactionAppBar> {
  DateTime _filterDate;
  var _isActionMode = false;
  var _items = <Transaction>[];

  _TransactionAppBarState(this._filterDate);

  void showActionMode(List<Transaction> items) {
    setState(() {
      _isActionMode = true;
      _items = items;
    });
  }

  void exitActionMode() {
    setState(() => _isActionMode = false);
    if (widget.onExitActionMode != null) widget.onExitActionMode();
  }

  Future<Null> _onMonthTap(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: _filterDate);
    if (picked == null) return;
    setState(() => _filterDate = picked);
    if (widget.onDateChange != null) widget.onDateChange(picked);
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
        backgroundColor: _isActionMode ? kBgActionMode : null,
        leading: _isActionMode ? new IconButton(icon: kIconBack, onPressed: () {
          exitActionMode();
        }) : null,
        title: _isActionMode ? new Text(_items.length.toString()) : _dateTitle(),
        actions: actions,
      ),
      onWillPop: _onWillPop,
    );
  }

  Widget _dateTitle() {
    return new InkWell(
      onTap: () => _onMonthTap(context),
      child: new Container(
        height: kToolbarHeight,
        child: new Row(children: <Widget>[
          new Text(new DateFormat.yMMM().format(_filterDate),
              style: Theme.of(context).primaryTextTheme.title),
          new Icon(Icons.arrow_drop_down),
        ]),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isActionMode) return true;
    exitActionMode();
    return false;
  }
}
