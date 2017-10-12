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
  final String bookId;

  const HomePage({@required this.bookId}) : assert(bookId != null);

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  var _currentRoute = HomePageTransaction.kRouteName;
  var _filterDate = new DateTime.now();
  var _isActionMode = true;
  var _selectedCount = 0;

  HomePageTransaction _homeTrans;
  HomePageBill _homeBill;
  HomePageBudget _homeBudget;

  AppBarTransaction _appBarTrans;
  AppBarBill _appBarBill;
  AppBarBudget _appBarBudget;

  @override
  void initState() {
    super.initState();

    _appBarTrans = new AppBarTransaction(initialDate: _filterDate, onDateChange: _onDateChange);
    _appBarBill = new AppBarBill();
    _appBarBudget = new AppBarBudget();

    _homeTrans = new HomePageTransaction(bookId: widget.bookId, date: _filterDate);
    _homeBill = new HomePageBill(bookId: widget.bookId);
    _homeBudget = new HomePageBudget(
      bookId: widget.bookId,
      onItemSelect: (Budget item) {

      }
    );
  }

  void _onDrawerChange(String route) {
    setState(() => _currentRoute = route);
  }

  void _onDateChange(DateTime date) {
    setState(() => _filterDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(),
      drawer: new AppDrawer(selectedRoute: _currentRoute, onListTap: _onDrawerChange),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    if (_isActionMode) return _buildActionMode();

    switch (_currentRoute) {
      case HomePageTransaction.kRouteName:
        return _appBarTrans;
      case HomePageBill.kRouteName:
        return _appBarBill;
      case HomePageBudget.kRouteName:
        return _appBarBudget;
    }
    return new AppBar(title: new Text(Lang.of(context).title()));
  }

  Widget _buildActionMode() {
    return new AppBar(
      leading: new IconButton(icon: kIconBack, onPressed: () {
        setState(() => _isActionMode = false);
      }),
      backgroundColor: Colors.black54,
      title: new Text(_selectedCount.toString()),
      actions: <Widget>[
        new IconButton(
          icon: kIconEdit,
          tooltip: Lang.of(context).menuEdit(),
          onPressed: () => null,
        ),
        new IconButton(
          icon: kIconDelete,
          tooltip: Lang.of(context).menuDelete(),
          onPressed: () => null,
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentRoute) {
      case HomePageTransaction.kRouteName:
        return _homeTrans;
      case HomePageBill.kRouteName:
        return _homeBill;
      case HomePageBudget.kRouteName:
        return _homeBudget;
    }
    return new Container();
  }

  Widget _buildFAB() {
    return new FloatingActionButton(
      child: kIconAdd,
      tooltip: Lang.of(context).btnAdd(),
      onPressed: () {
        switch (_currentRoute) {
          case HomePageTransaction.kRouteName:
            Navigator.pushNamed(context, TransactionPage.kRouteName);
            return;
          case HomePageBill.kRouteName:

            return;
          case HomePageBudget.kRouteName:
            Navigator.pushNamed(context, BudgetPage.kRouteName);
            return;
        }
      },
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
