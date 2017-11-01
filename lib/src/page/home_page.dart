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
part 'home_page_note.dart';
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
  final _transBarKey = new GlobalKey<_TransactionAppBarState>();
  final _transKey = new GlobalKey<_HomePageTransactionState>();
  final _budgetBarKey = new GlobalKey<ListAppBarState<Budget>>();
  final _budgetKey = new GlobalKey<_HomePageBudgetState>();
  final _billBarKey = new GlobalKey<ListAppBarState<BillGroup>>();
  final _billKey = new GlobalKey<_HomePageBillState>();
  final _noteBarKey = new GlobalKey<ListAppBarState<Note>>();
  final _noteKey = new GlobalKey<_HomePageNoteState>();

  var _currentRoute = HomePageTransaction.kRouteName;

  HomePageTransaction _homeTrans;
  HomePageBill _homeBill;
  HomePageBudget _homeBudget;
  HomePageNote _homeNote;

  TransactionAppBar _appBarTrans;
  ListAppBar<BillGroup> _appBarBill;
  ListAppBar<Budget> _appBarBudget;
  ListAppBar<Note> _appBarNote;

  @override
  void initState() {
    super.initState();

    Book.getNode(currentUser.uid).keepSynced(true);
    Budget.getNode(currentBook.id).keepSynced(true);
    BillGroup.getNode(currentBook.id).keepSynced(true);
    Bill.getNode(currentBook.id).keepSynced(true);
    Transaction.getNode(currentBook.id).keepSynced(true);
    Balance.getNode(currentBook.id).keepSynced(true);
    Note.getNode(currentBook.id).keepSynced(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initTrans();
    _initBill();
    _initBudget();
    _initNote();
  }

  void _initTrans() {
    final lang = Lang.of(context);
    final initialDate = new DateTime.now();
    _appBarTrans = new TransactionAppBar(
      key: _transBarKey,
      initialDate: initialDate,
      onDateChange: (date) => _transKey.currentState.setDate(date),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'id': items[0].id};
            Navigator.pushNamed(context, routeWithParams(TransactionPage.kRouteName, params));
            _transBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Transaction.remove(currentBook.id, val.id));
              _transBarKey.currentState.exitActionMode();
            });
            break;
        }
      },
      onExitActionMode: () {
        _transKey.currentState.clearSelection();
      },
    );

    _homeTrans = new HomePageTransaction(
      key: _transKey,
      bookId: widget.bookId,
      date: initialDate,
      config: widget.config,
      onItemTap: (item) {
        final params = <String, dynamic>{'id': item.id};
        Navigator.pushNamed(context, routeWithParams(TransactionPage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          _transBarKey.currentState.exitActionMode();
        else
          _transBarKey.currentState.showActionMode(items);
      },
    );
  }

  void _initBill() {
    final lang = Lang.of(context);
    _appBarBill = new ListAppBar<BillGroup>(
      key: _billBarKey,
      title: lang.titleBill(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'id': items[0].id};
            Navigator.pushNamed(context, routeWithParams(BillPage.kRouteName, params));
            _billBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Bill.remove(currentBook.id, val.id));
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
      },
    );
  }

  void _initBudget() {
    final lang = Lang.of(context);
    _appBarBudget = new ListAppBar<Budget>(
      key: _budgetBarKey,
      title: lang.titleBudget(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'id': items[0].id};
            Navigator.pushNamed(context, routeWithParams(BudgetPage.kRouteName, params));
            _budgetBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Budget.remove(currentBook.id, val.id));
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
        final params = <String, dynamic>{'id': item.id};
        Navigator.pushNamed(context, routeWithParams(BudgetViewPage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          _budgetBarKey.currentState.exitActionMode();
        else
          _budgetBarKey.currentState.showActionMode(items);
      }
    );
  }

  void _initNote() {
    final lang = Lang.of(context);
    _appBarNote = new ListAppBar<Note>(
      key: _noteBarKey,
      title: lang.titleNote(),
      onActionModeTap: (key, items) {
        switch (key) {
          case 'edit':
            final params = <String, dynamic>{'id': items[0].id};
            Navigator.pushNamed(context, routeWithParams(NotePage.kRouteName, params));
            _noteBarKey.currentState.exitActionMode();
            break;
          case 'delete':
            showConfirmDialog(context, new Text(lang.msgConfirmDelete())).then((ret) {
              if (!ret) return;
              items.forEach((val) => Note.remove(currentBook.id, val.id));
              _noteBarKey.currentState.exitActionMode();
            });
            break;
        }
      },
      onExitActionMode: () {
        _noteKey.currentState.clearSelection();
      },
    );

    _homeNote = new HomePageNote(
      key: _noteKey,
      bookId: widget.bookId,
      config: widget.config,
      onItemTap: (item) {
        final params = <String, dynamic>{'id': item.id};
        Navigator.pushNamed(context, routeWithParams(NotePage.kRouteName, params));
      },
      onItemsSelect: (items, index) {
        if (items.length == 0)
          _noteBarKey.currentState.exitActionMode();
        else
          _noteBarKey.currentState.showActionMode(items);
      }
    );
  }

  void _onDrawerChange(String route) {
    if (route == SettingsPage.kRouteName) {
      Navigator.pushNamed(context, SettingsPage.kRouteName);
      return;
    }
    setState(() => _currentRoute = route);
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
      case HomePageNote.kRouteName:
        return _appBarNote;
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
      case HomePageNote.kRouteName:
        return _homeNote;
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
          case HomePageNote.kRouteName:
            Navigator.pushNamed(context, NotePage.kRouteName);
            return;
        }
      },
    );
  }
}
