

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

  const HomePageTransaction({Key key, @required this.bookId, this.date, this.config})
    : assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageTransactionState();
}

class _HomePageTransactionState extends State<HomePageTransaction>
    with SingleTickerProviderStateMixin {
  var _isLoading = true;

  AnimationController _animationCtrl;
  Animation<double> _animation;

  List<Transaction> _items;
  StreamSubscription<Event> _dataSubscr;

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
    final dateStart = new DateTime(widget.date.year, widget.date.month);
    final dateEnd = new DateTime(widget.date.year, widget.date.month + 1, 0);
    final openingBalance = await Balance.get(bookId, widget.date.year, widget.date.month);
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
        decoration: new BoxDecoration(color: Colors.black12),
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
        padding: const EdgeInsets.only(top: 8.0, bottom: 72.0),
        itemCount: _items.length,
        itemExtent: 50.0,
        itemBuilder: (context, index) {
          if (index == _items.length - 1) {
            return new ListTile(
              title: new Center(child: new Text(
                lang.titleOpeningBalance().toUpperCase(),
                style: theme.textTheme.body1.copyWith(color: Colors.black54),
              )),
              subtitle: new Center(child: new Text(
                currFormatter.format(_items[index].balance),
                style: theme.textTheme.title.copyWith(color: Colors.black54),
              )),
            );
          } else {
            return new _ContentTransactionItem(
              context: context,
              item: _items[index],
              currencySymbol: widget.config?.currencySymbol,
            );
          }
        },
      )),
    ]);
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

  const _ContentTransactionItem({@required this.context, @required this.item,
                                 this.currencySymbol})
    : assert(context != null),
      assert(item != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFormatter = new NumberFormat.currency(symbol: currencySymbol);

    return new ListTile(
      title: new Text(
        item.title ?? '',
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
        margin: const EdgeInsets.only(top: 8.0),
        child: new Text(
          currFormatter.format(item.balance),
          style: theme.textTheme.subhead.copyWith(color: Colors.black54),
        ),
      ),
    );
  }
}

class TransactionAppBar extends StatefulWidget implements PreferredSizeWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChange;
  final ValueChanged<String> onActionTap;
  final Size preferredSize;

  TransactionAppBar({Key key, DateTime initialDate, this.onDateChange, this.onActionTap})
    : this.initialDate = initialDate ?? new DateTime.now(),
      preferredSize = new Size.fromHeight(kToolbarHeight),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _TransactionAppBarState(initialDate);
}

class _TransactionAppBarState extends State<TransactionAppBar> {
  DateTime _filterDate;

  _TransactionAppBarState(this._filterDate);

  Future<Null> _onMonthTap(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: _filterDate);
    if (picked == null) return;
    setState(() => _filterDate = picked);
    if (widget.onDateChange != null) widget.onDateChange(picked);
  }

  void _onActionTap(String name) {
    if (widget.onActionTap != null) widget.onActionTap(name);
  }

  @override
  Widget build(BuildContext context) {
    return new AppBar(
      title: new InkWell(
        onTap: () => _onMonthTap(context),
        child: new Container(
          height: kToolbarHeight,
          child: new Row(children: <Widget>[
            new Text(new DateFormat.yMMM().format(_filterDate),
                style: Theme.of(context).primaryTextTheme.title),
            new Icon(Icons.arrow_drop_down),
          ]),
        ),
      ),
      actions: <Widget>[
        new IconButton(
          icon: kIconSearch,
          tooltip: Lang.of(context).menuSearch(),
          onPressed: () => _onActionTap('search'),
        ),
        new PopupMenuButton<String>(
          onSelected: (name) => _onActionTap(name),
          itemBuilder: (context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'menu_1',
              child: const Text('Toolbar menu'),
            ),
            const PopupMenuItem<String>(
              value: 'menu_2',
              child: const Text('Right here'),
            ),
            const PopupMenuItem<String>(
              value: 'menu_3',
              child: const Text('Hooray!'),
            ),
          ],
        ),
      ],
    );
  }

}
