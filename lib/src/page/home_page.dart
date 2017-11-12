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
import 'package:financial_note/strings.dart';
import 'package:financial_note/utils.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
  static const notificationChannel = const MethodChannel(kNotificationChannel);
  final _messaging = new FirebaseMessaging();
  var _currentRoute = TransactionListPage.kRouteName;

  HomePageTransaction _homeTrans;
  HomePageBill _homeBill;
  HomePageBudget _homeBudget;
  HomePageNote _homeNote;

  @override
  void initState() {
    super.initState();

    getNode(User.kNodeName, null).child(currentUser.uid).keepSynced(true);
    getNode(Book.kNodeName, currentUser.uid).keepSynced(true);
    getNode(Budget.kNodeName, currentBook.id).keepSynced(true);
    getNode(BillGroup.kNodeName, currentBook.id).keepSynced(true);
    getNode(Bill.kNodeName, currentBook.id).keepSynced(true);
    getNode(Transaction.kNodeName, currentBook.id).keepSynced(true);
    getNode(Balance.kNodeName, currentBook.id).keepSynced(true);
    getNode(Note.kNodeName, currentBook.id).keepSynced(true);

    _initMessaging();
  }

  void _initMessaging() {
    _messaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true)
    );

    // TODO: Ganti subscribe to topic dengan device group
    _messaging.subscribeToTopic(currentBook.id);

    _messaging.configure(
      onMessage: (message) {
        print('Messaging on message');
        final action = valueOf<String>(message, 'action');
        if (action == kScheduleNotification) {
          final id = valueOf<String>(message, 'ref_id');
          _scheduleNoteNotification(id);
        }
      },
      onResume: (message) {
        print('Messaging on resume');
        _handleOnResume(message);
      },
      onLaunch: (message) {
        print('Messaging on launch');
        _handleOnResume(message);
      }
    );
  }

  Future<Null> _scheduleNoteNotification(String id) async {
    final note = await Note.of(widget.bookId).get(id);
    if (note == null || note.reminder == null) return;

    try {
      final args = <String, dynamic>{
        'date'    : formatDate(note.reminder, 'yyyy-MM-dd HH:mm:ss'),
        'ticker'  : note.note,
        'title'   : note.title,
        'content' : note.note,
        'action'  : kShowNote,
        'ref_id'  : note.id,
      };
      await notificationChannel.invokeMethod(kScheduleNotification, args);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void _handleOnResume(Map<String, dynamic> message) {
    final action = valueOf<String>(message, 'action');
    if (action == kShowNote) {
      final id = valueOf<String>(message, 'ref_id');
      final route = buildRoute(NotePage.kRouteName, <String, dynamic>{'id': id});
      Navigator.pushNamed(context, route);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _homeTrans = new HomePageTransaction(
      context: context,
      config: widget.config,
      bookId: widget.bookId,
    );
    _homeBill = new HomePageBill(
      context: context,
      config: widget.config,
      bookId: widget.bookId,
    );
    _homeBudget = new HomePageBudget(
      context: context,
      config: widget.config,
      bookId: widget.bookId,
    );
    _homeNote = new HomePageNote(
      context: context,
      config: widget.config,
      bookId: widget.bookId,
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
    Widget appBar;
    Widget body;
    switch (_currentRoute) {
      case TransactionListPage.kRouteName:
        appBar = _homeTrans.appBar;
        body = _homeTrans.body;
        break;
      case BillListPage.kRouteName:
        appBar = _homeBill.appBar;
        body = _homeBill.body;
        break;
      case BudgetListPage.kRouteName:
        appBar = _homeBudget.appBar;
        body = _homeBudget.body;
        break;
      case NoteListPage.kRouteName:
        appBar = _homeNote.appBar;
        body = _homeNote.body;
        break;
    }

    return new Scaffold(
      appBar: appBar,
      drawer: new AppDrawer(selectedRoute: _currentRoute, onListTap: _onDrawerChange),
      body: body,
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return new FloatingActionButton(
      child: kIconAdd,
      tooltip: Lang.of(context).btnAdd(),
      onPressed: () {
        switch (_currentRoute) {
          case TransactionListPage.kRouteName:
            Navigator.pushNamed(context, TransactionPage.kRouteName);
            return;
          case BillListPage.kRouteName:
            Navigator.pushNamed(context, BillPage.kRouteName);
            return;
          case BudgetListPage.kRouteName:
            Navigator.pushNamed(context, BudgetPage.kRouteName);
            return;
          case NoteListPage.kRouteName:
            Navigator.pushNamed(context, NotePage.kRouteName);
            return;
        }
      },
    );
  }
}
