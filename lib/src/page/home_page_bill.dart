/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page_bill_list;

class HomePageBill {
  final appBarKey = new GlobalKey<ListAppBarState<BillGroup>>();
  final bodyKey = new GlobalKey<_BillListPageState>();

  final Config config;
  final String bookId;
  final BuildContext context;
  final Lang _lang;

  Widget _appBar;
  Widget _body;

  Widget get appBar => _appBar;
  Widget get body => _body;

  HomePageBill({
    @required this.context, @required this.config, @required this.bookId,
  }) : assert(context != null),
       assert(config != null),
       assert(bookId != null),
       _lang = Lang.of(context) {
    _initAppBar();
    _initList();
  }

  void _initAppBar() {
    _appBar = new ListAppBar<BillGroup>(
      key: appBarKey,
      title: _lang.titleBill(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = {'id': items[0].id};
            Navigator.pushNamed(context, buildRoute(BillPage.kRouteName, params));
            appBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(_lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => BillGroup.of(currentBook.id).removeById(val.id));
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
    _body = new BillListPage(
      key: bodyKey,
      bookId: bookId,
      config: config,
      onItemTap: (item) {
        final params = {'id': item.id};
        Navigator.pushNamed(context, buildRoute(BillViewPage.kRouteName, params));
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
