

/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page;

class HomePageTransaction extends StatefulWidget {
  static const kRouteName = '/home-transactions';

  final Config config;
  final String bookId;
  final DateTime date;

  final OnItemTap<Transaction> onItemTap;
  final OnItemSelect<Transaction> onItemsSelect;

  const HomePageTransaction({
    Key key, @required this.bookId, this.date, this.onItemTap, this.onItemsSelect,
    this.config
  }) : assert(bookId != null),
       super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageTransactionState(date);
}

class _HomePageTransactionState extends State<HomePageTransaction>
    with SingleTickerProviderStateMixin {
  final List<Transaction> _selectedItems = [];
  var _isLoading = true;
  DateTime _filterDate;

  AnimationController _animationCtrl;
  Animation<double> _animation;

  List<Transaction> _items;
  StreamSubscription<Event> _dataSubscr;

  _HomePageTransactionState(DateTime date) : _filterDate = date;

  @override
  void initState() {
    super.initState();

    _initProgress();

    _dataSubscr = Transaction.ref(widget.bookId).onChildChanged.listen((event) {
      _refreshData(widget.bookId);
    });
    _refreshData(widget.bookId);
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
    final dateStart = new DateTime(_filterDate.year, _filterDate.month);
    final dateEnd = new DateTime(_filterDate.year, _filterDate.month + 1, 0);
    final openingBalance = await Balance.get(bookId, _filterDate.year, _filterDate.month);
    final items = await Transaction.list(bookId, dateStart, dateEnd, openingBalance);

    items.add(new Transaction(
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
      return new _EmptyBody(isLoading: _isLoading);

    final theme = Theme.of(context);
    final lang = Lang.of(context);

    final currFormatter = new NumberFormat.currency(symbol: widget.config?.currencySymbol);
    final balance = _items.length > 0 ? _items[0].balance : 0.0;

    return new Column(children: <Widget>[
      new Container(
        decoration: new BoxDecoration(color: Colors.blueGrey[100]),
        child: new ListTile(
          title: new Center(child: new Text(
            lang.titleBalance().toUpperCase(),
            style: theme.textTheme.body1.copyWith(color: Colors.black54),
          )),
          subtitle: new Center(child: new Text(
            currFormatter.format(balance),
            style: theme.textTheme.title.copyWith(color: Colors.black87),
          )),
        ),
      ),
      new Expanded(child: new ListView.builder(
        padding: const EdgeInsets.only(bottom: 72.0),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          if (_items.length <= 1) {
            return new _EmptyBody();
          } else if (index == _items.length - 1) {
            return new ListTile(
              title: new Center(child: new Text(
                lang.titleOpeningBalance().toUpperCase(),
                style: theme.textTheme.body1.copyWith(color: Colors.black54),
              )),
              subtitle: new Center(child: new Text(
                currFormatter.format(item.balance),
                style: theme.textTheme.title.copyWith(color: Colors.black54),
              )),
            );
          } else {
            return new _ContentTransactionItem(
              context: context,
              item: item,
              currencySymbol: widget.config?.currencySymbol,
              selected: _getSelectedIndex(_selectedItems, item) != -1,
              onTap: () => _onTap(item),
              onLongPress: () => _onLongPress(item),
            );
          }
        },
      )),
    ]);
  }

  void _onTap(Transaction item) {
    if (_selectedItems.length > 0) {
      final idx = _getSelectedIndex(_selectedItems, item);
      if (idx >= 0) {
        setState(() => _selectedItems.removeAt(idx));
      } else {
        setState(() => _selectedItems.add(item));
      }
      if (widget.onItemsSelect != null) {
        widget.onItemsSelect(_selectedItems, idx);
      }
    } else {
      if (widget.onItemTap != null) {
        widget.onItemTap(item);
      }
    }
  }

  void _onLongPress(Transaction data) {
    if (_selectedItems.length > 0) return;

    setState(() => _selectedItems.add(data));
    if (widget.onItemsSelect != null) {
      widget.onItemsSelect(_selectedItems, 0);
    }
  }

  int _getSelectedIndex(List<Transaction> items, Transaction item) {
    if (items == null) return -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == item.id) return i;
    }
    return -1;
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
    super.dispose();
    if (_dataSubscr != null) _dataSubscr.cancel();
  }
}

class _ContentTransactionItem extends StatelessWidget {
  final BuildContext context;
  final Transaction item;
  final String currencySymbol;

  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool selected;

  const _ContentTransactionItem({
    @required this.context, @required this.item,
    this.currencySymbol, this.selected, this.onTap, this.onLongPress
  }) : assert(context != null),
       assert(item != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFormatter = new NumberFormat.currency(symbol: currencySymbol);
    final selectedBg = new BoxDecoration(color: theme.highlightColor);

    return new Container(
      decoration: selected ? selectedBg : null,
      child: new ListTile(
        dense: true,
        title: new Text(
          item.title ?? '',
          style: theme.textTheme.subhead,
        ),
        subtitle: new Text(
          (item.value >= 0 ? '+' : '') + currFormatter.format(item.value),
          style: theme.textTheme.body2.copyWith(
            color: item.value >= 0 ? Colors.green[500] : Colors.orange[600],
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: new Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(top: 14.0),
          child: new Text(
            currFormatter.format(item.balance),
            style: theme.textTheme.subhead.copyWith(color: Colors.black54),
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
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
