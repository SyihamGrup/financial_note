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

class HomePage extends StatefulWidget {
  static const kRouteName = '/home';

  final Config config;

  const HomePage(this.config);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  var _isLoading = true;
  var _filterDate = new DateTime.now();
  AnimationController _animationCtrl;
  Animation<double> _animation;
  List<Transaction> _data;
  StreamSubscription<Event> _dataSubscr;

  @override
  void initState() {
    super.initState();

    _animationCtrl =  new AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _animation = new CurvedAnimation(
      parent: _animationCtrl,
      curve: const Interval(0.0, 0.9, curve: Curves.fastOutSlowIn),
      reverseCurve: Curves.fastOutSlowIn
    );

    initData();
  }

  Future<Null> initData() async {
    final user = await ensureLoggedIn();
    if (user == null) {
      Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
      return;
    }

    Book.ref(user.uid).keepSynced(true);

    final book = await Book.getDefault(user.uid);

    _dataSubscr = Transaction.ref(book.id).onChildChanged.listen((event) {
      updateData(book.id);
    });
    updateData(book.id);
  }

  Future<Null> updateData(String bookId) async {
    setState(() => _isLoading = true);

    final dateStart = new DateTime(_filterDate.year, _filterDate.month);
    final dateEnd = new DateTime(_filterDate.year, _filterDate.month + 1, 0);
    final openingBalance = await Transaction.getOpeningBalance(bookId, dateStart);
    final data = await Transaction.list(bookId, dateStart, dateEnd, openingBalance);
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_dataSubscr != null) _dataSubscr.cancel();
  }

  Future<Null> _selectMonth(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: _filterDate);
    if (picked == null) return;

    setState(() => _filterDate = picked);
  }

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(
      title: new InkWell(
        onTap: () => _selectMonth(context),
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
          onPressed: () => null,
        ),
        new PopupMenuButton<String>(
          onSelected: (String item) => null,
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'Toolbar menu',
              child: const Text('Toolbar menu')
            ),
            const PopupMenuItem<String>(
              value: 'Right here',
              child: const Text('Right here')
            ),
            const PopupMenuItem<String>(
              value: 'Hooray!',
              child: const Text('Hooray!')
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
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
        return new _ContentItem(context, item);
      },
    );
  }

  Widget _buildProgress(bool isLoading) {
    return new AnimatedBuilder(animation: _animation, builder: (context, child) {
      if (!isLoading) return new Container();
      return const SizedBox(height: 2.0, child: const LinearProgressIndicator());
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(context),
      drawer: new AppDrawer(),
      body: new Stack(children: <Widget>[
        _buildBody(),
        _buildProgress(_isLoading),
      ]),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, TransactionPage.kRouteName),
        tooltip: Lang.of(context).btnAdd(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ContentItem extends StatelessWidget {
  final BuildContext context;
  final Transaction item;

  const _ContentItem(this.context, this.item);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(item.title ?? ''),
      subtitle: new Text('Balance: ${item.balance}'),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final isLoading;

  _EmptyBody({this.isLoading: false});

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return new Center(child: new Text(
      isLoading ? lang.msgLoading() : lang.msgEmptyData()));
  }
}
