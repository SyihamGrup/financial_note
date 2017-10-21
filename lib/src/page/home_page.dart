/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page;

import 'dart:async';

import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/page.dart';
import 'package:financial_note/src/page/bill_page.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

part 'home_page_bill.dart';
part 'home_page_budget.dart';
part 'home_page_transaction.dart';

class HomePage extends StatefulWidget {
  static const kRouteName = '/home';
  final Config config;
  final String bookId;

  const HomePage({Key key, @required this.bookId, this.config})
    : assert(bookId != null),
      super(key: key);

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _budgetBarKey = new GlobalKey<ListAppBarState<Budget>>();
  final _budgetKey = new GlobalKey<_HomePageBudgetState>();
  final _billBarKey = new GlobalKey<ListAppBarState<BillGroup>>();
  final _billKey = new GlobalKey<_HomePageBillState>();

  var _currentRoute = HomePageTransaction.kRouteName;
  var _filterDate = new DateTime.now();

  HomePageTransaction _homeTrans;
  HomePageBill _homeBill;
  HomePageBudget _homeBudget;

  AppBarTransaction _appBarTrans;
  ListAppBar<BillGroup> _appBarBill;
  ListAppBar<Budget> _appBarBudget;

  @override
  void initState() {
    super.initState();

    final ref = FirebaseDatabase.instance.reference();
    ref.child(Book.kNodeName).child(currentUser.uid).keepSynced(true);
    ref.child(Budget.kNodeName).child(currentBook.id).keepSynced(true);
    ref.child(BillGroup.kNodeName).child(currentBook.id).keepSynced(true);
    ref.child(Bill.kNodeName).child(currentBook.id).keepSynced(true);
    ref.child(Balance.kNodeName).child(currentBook.id).keepSynced(true);
    ref.child(Transaction.kNodeName).child(currentBook.id).keepSynced(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initTrans();
    _initBill();
    _initBudget();
  }

  void _initTrans() {
    _appBarTrans = new AppBarTransaction(initialDate: _filterDate, onDateChange: _onDateChange);

    _homeTrans = new HomePageTransaction(bookId: widget.bookId, date: _filterDate);
  }

  void _initBill() {
    final lang = Lang.of(context);
    _appBarBill = new ListAppBar<BillGroup>(
      key: _billBarKey,
      title: lang.titleBill(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'data': items[0]};
            Navigator.pushNamed(context, routeWithParams(BillPage.kRouteName, params));
            _billBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Bill.ref(currentBook.id).child(val.id).remove());
              _billBarKey.currentState.exitActionMode();
            });
            break;
        }
      },
      onExitActionMode: () {
        _billKey.currentState.clearSelection();
      },
    );

    _homeBill = new HomePageBill(
      key: _billKey,
      bookId: widget.bookId,
      config: widget.config,
      onItemTap: (item) {
        final params = <String, dynamic>{'id': item.id};
        Navigator.pushNamed(context, routeWithParams(BillPage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          _billBarKey.currentState.exitActionMode();
        else
          _billBarKey.currentState.showActionMode(items);
      });
  }

  void _initBudget() {
    final lang = Lang.of(context);
    _appBarBudget = new ListAppBar<Budget>(
      key: _budgetBarKey,
      title: lang.titleBudget(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'data': items[0]};
            Navigator.pushNamed(context, routeWithParams(BudgetPage.kRouteName, params));
            _budgetBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Budget.ref(currentBook.id).child(val.id).remove());
              _budgetBarKey.currentState.exitActionMode();
            });
            break;
        }
      },
      onExitActionMode: () {
        _budgetKey.currentState.clearSelection();
      },
    );

    _homeBudget = new HomePageBudget(
      key: _budgetKey,
      bookId: widget.bookId,
      config: widget.config,
      onItemTap: (item) {
        final params = <String, dynamic>{'data': item};
        Navigator.pushNamed(context, routeWithParams(BudgetPage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          _budgetBarKey.currentState.exitActionMode();
        else
          _budgetBarKey.currentState.showActionMode(items);
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
            Navigator.pushNamed(context, BillPage.kRouteName);
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
