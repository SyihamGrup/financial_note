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
  static const kRouteName = '/';

  final Config config;

  const HomePage(this.config);

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  var _filterDate = new DateTime.now();
  List<Transaction> _data;
  StreamSubscription<Event> _dataSubscr;

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<Null> initData() async {
    var user = await ensureLoggedIn();
    if (user == null) {
      Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
      return;
    }

    Book.ref(user.uid).keepSynced(true);

    var book = await Book.getDefault(user.uid);

    _dataSubscr = Transaction.ref(book.id).onChildChanged.listen((event) {
      updateData(book.id);
    });
    updateData(book.id);
  }

  Future<Null> updateData(String bookId) async {
    final dateStart = new DateTime(_filterDate.year, _filterDate.month);
    final dateEnd = new DateTime(_filterDate.year, _filterDate.month + 1, 0);
    var data = await Transaction.list(context, bookId, dateStart, dateEnd);
    setState(() => _data = data);
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

  Widget _buildBody(BuildContext context) {
    if (_data == null || _data.length == 0) return new _EmptyBody();

    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _data.length,
      itemExtent: 40.0,
      itemBuilder: (context, index) => new _ContentItem(context, _data[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(context),
      drawer: new AppDrawer(),
      body: _buildBody(context),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => null,
        tooltip: 'Increment',
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
      title: new Text(item.descr ?? ''),
      subtitle: new Text('Balance: ${item.balance}'),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(child: new Text(Lang.of(context).msgEmptyData()));
  }
}
