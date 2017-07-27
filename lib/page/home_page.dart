// Copyright (c) 2017. All rights reserved.
//
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//
// Written by:
//   - Adi Sayoga <adisayoga@gmail.com>

import 'dart:async';

import 'package:financial_note/data/book.dart';
import 'package:financial_note/data/config.dart';
import 'package:financial_note/i18n/strings.dart';
import 'package:financial_note/widget/drawer.dart';
import 'package:financial_note/widget/month_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  final Config config;
  final ValueChanged<Config> updateConfig;

  const HomePage(this.config, this.updateConfig);

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  var _filterDate = new DateTime.now();

  StreamSubscription<Event> _bookSubscr;


//  var _counter = 0;
//  final _data = new List<Transaction>();
//  StreamSubscription<Event> _dataSubscr;

//  final _counterRef = FirebaseDatabase.instance.reference().child(Counter.name);
//  final _messagesRef = FirebaseDatabase.instance.reference().child(Message.name);

//  StreamSubscription<Event> _counterSubscr;
//  StreamSubscription<Event> _messageSubscr;

  @override
  void initState() {
    super.initState();

    Book.ref.keepSynced(true);
    _bookSubscr = Book.ref.onValue.listen((event) {
      print(event.snapshot.value);
    });

//    _counterRef.keepSynced(true);
//
//    _dataSubscr = Transaction.listen((event) {
//    });
//
//    _counterSubscr = _counterRef.onValue.listen((Event event) {
//      setState(() => _counter = event.snapshot.value ?? 0);
//    });
//
//    _messageSubscr = _messagesRef.onValue.listen((Event event) {
//      print('Child added : ${event.snapshot.value}');
//    });
  }

  @override
  void dispose() {
    super.dispose();

    _bookSubscr.cancel();
//    _messageSubscr.cancel();
//    _counterSubscr.cancel();
  }

  Future<Null> _selectMonth(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: _filterDate);
    if (picked == null) return;

    setState(() => _filterDate = picked);
  }

  Future<Null> _increment() async {
//    setState(() => _counter++);
//
//    await ensureLoggedIn();
//
//    // TODO(jackson): This illustrates a case where transactions are needed
//    final snapshot = await _counterRef.once();
//    setState(() => _counter = (snapshot.value ?? 0) + 1);
//    _counterRef.set(_counter);
//
//    _messagesRef.push().set(<String, String>{'Hello': 'World $_counter'});
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
    return new Column(children: <Widget>[
      new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(children: <Widget>[
          new Text(
            '...',
//           'Button tapped $_counter time${_counter == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.title,
          ),
          new Text('This includes all devices, ever.'),
        ]),
      ),
//      new Flexible(child: new FirebaseAnimatedList(
//        query: _messagesRef,
//        reverse: true,
//        sort: (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key),
//        itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation) {
//          return new SizeTransition(
//            sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
//            child: new Container(
//              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//              child: new Text(snapshot.value.toString()),
//            ),
//          );
//        },
//      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(context),
      drawer: new AppDrawer(),
      body: _buildBody(context),
      floatingActionButton: new FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
