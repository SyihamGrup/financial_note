/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page_budget_list;

class HomePageBudget {
  final appBarKey = new GlobalKey<ListAppBarState<Budget>>();
  final bodyKey = new GlobalKey<_BudgetListPageState>();

  final Config config;
  final String bookId;
  final ValueChanged<bool> onActionModeChange;
  final BuildContext context;
  final Lang _lang;

  Widget _appBar;
  Widget _body;

  Widget get appBar => _appBar;
  Widget get body => _body;

  HomePageBudget({
    @required this.context, @required this.config, @required this.bookId,
    this.onActionModeChange,
  }) : assert(context != null),
       assert(config != null),
       assert(bookId != null),
       _lang = Lang.of(context) {
    _initAppBar();
    _initList();
  }

  void _initAppBar() {
    _appBar = new ListAppBar<Budget>(
      key: appBarKey,
      title: _lang.titleBudget(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = {'id': items[0].id};
            Navigator.pushNamed(context, buildRoute(BudgetPage.kRouteName, params));
            appBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showDeleteConfirmDialog(context).then((ret) {
              if (!ret) return;
              items.forEach((val) => Budget.of(currentBook.id).removeById(val.id));
              appBarKey.currentState.exitActionMode();
            });
            break;
        }
      },
      onStartActionMode: () {
        if (onActionModeChange != null) onActionModeChange(true);
      },
      onExitActionMode: () {
        bodyKey.currentState.clearSelection();
        if (onActionModeChange != null) onActionModeChange(false);
      },
    );
  }

  void _initList() {
    _body = new BudgetListPage(
      key: bodyKey,
      bookId: bookId,
      config: config,
      onItemTap: (item) {
        final params = {'id': item.id};
        Navigator.pushNamed(context, buildRoute(BudgetViewPage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          appBarKey.currentState.exitActionMode();
        else
          appBarKey.currentState.showActionMode(items);
      }
    );
  }
}
