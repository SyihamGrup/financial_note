/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page_transaction_list;

class HomePageTransaction {
  final appBarKey = new GlobalKey<_TransactionAppBarState>();
  final bodyKey = new GlobalKey<_TransactionListPageState>();

  final Config config;
  final String bookId;
  final BuildContext context;
  final Lang _lang;

  Widget _appBar;
  Widget _body;

  Widget get appBar => _appBar;
  Widget get body => _body;

  HomePageTransaction({
    @required this.context, @required this.config, @required this.bookId,
  }) : assert(context != null),
       assert(config != null),
       assert(bookId != null),
       _lang = Lang.of(context) {
    _initAppBar();
    _initList();
  }

  void _initAppBar() {
    final initialDate = new DateTime.now();
    _appBar = new TransactionAppBar(
      key: appBarKey,
      initialDate: initialDate,
      onDateChange: (date) => bodyKey.currentState.setDate(date),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'id': items[0].id};
            Navigator.pushNamed(context, routeWithParams(TransactionPage.kRouteName, params));
            appBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(_lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Transaction.of(currentBook.id).removeById(val.id));
              appBarKey.currentState.exitActionMode();
            });
            break;
        }
      },
      onExitActionMode: () {
        bodyKey.currentState.clearSelection();
      },
    );
  }

  void _initList() {
    final initialDate = new DateTime.now();
    _body = new TransactionListPage(
      key: bodyKey,
      bookId: bookId,
      date: initialDate,
      config: config,
      onItemTap: (item) {
        final params = <String, dynamic>{'id': item.id};
        Navigator.pushNamed(context, routeWithParams(TransactionPage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          appBarKey.currentState.exitActionMode();
        else
          appBarKey.currentState.showActionMode(items);
      },
    );
  }
}
