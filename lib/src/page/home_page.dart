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

  const HomePage();

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  var _currentRoute = HomePageTransaction.kRouteName;
  var _filterDate = new DateTime.now();

  void _onDrawerChange(String route) {
    setState(() => _currentRoute = route);
  }

  void _onDateChange(DateTime date) {
    setState(() => _filterDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(_currentRoute),
      drawer: new AppDrawer(selectedRoute: _currentRoute, onListTap: _onDrawerChange),
      body: _buildBody(_currentRoute),
      floatingActionButton: _buildFAB(_currentRoute),
    );
  }

  Widget _buildAppBar(String route) {
    switch (route) {
      case HomePageTransaction.kRouteName:
        return new TransactionAppBar(initialDate: _filterDate, onDateChange: _onDateChange);
      case HomePageBill.kRouteName:
        return new AppBar(title: new Text(Lang.of(context).titleBill()));
      case HomePageBudget.kRouteName:
        return new AppBar(title: new Text(Lang.of(context).titleBudget()));
    }
    return new AppBar(title: new Text(Lang.of(context).title()));
  }

  Widget _buildBody(String route) {
    switch (route) {
      case HomePageTransaction.kRouteName:
        return new HomePageTransaction(date: _filterDate);
      case HomePageBill.kRouteName:
        return new HomePageBill();
    }
    return new Container();
  }

  Widget _buildFAB(String route) {
    switch (route) {
      case HomePageTransaction.kRouteName:
        return new FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, TransactionPage.kRouteName),
          tooltip: Lang.of(context).btnAdd(),
          child: const Icon(Icons.add),
        );
    }
    return null;
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
