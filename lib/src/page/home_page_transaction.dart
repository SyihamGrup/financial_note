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

  final String bookId;
  final DateTime date;

  const HomePageTransaction({@required this.bookId, this.date});

  @override
  State<StatefulWidget> createState() => new _HomePageTransactionState();
}

class _HomePageTransactionState extends State<HomePageTransaction>
    with SingleTickerProviderStateMixin {
  var _isLoading = true;

  AnimationController _animationCtrl;
  Animation<double> _animation;

  List<Transaction> _data;
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
    final data = await Transaction.list(bookId, dateStart, dateEnd, openingBalance);
    setState(() {
      _data = data;
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
    if (_data == null || _data.length == 0)
      return new _EmptyBody(isLoading: _isLoading);

    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _data.length,
      itemExtent: 40.0,
      itemBuilder: (context, index) {
        final item = (index == 0)
          ? _data[index].copyWith(title: Lang.of(context).titleOpeningBalance())
          : _data[index];
        return new _ContentTransactionItem(context, item);
      },
    );
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

  const _ContentTransactionItem(this.context, this.item);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(item.title ?? ''),
      subtitle: new Text('Balance: ${item.balance}'),
    );
  }
}

class TransactionAppBar extends StatefulWidget implements PreferredSizeWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChange;
  final ValueChanged<String> onActionTap;
  final Size preferredSize;

  TransactionAppBar({DateTime initialDate, this.onDateChange, this.onActionTap})
      : this.initialDate = initialDate ?? new DateTime.now(),
        preferredSize = new Size.fromHeight(kToolbarHeight);

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
          icon: const Icon(Icons.search),
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
