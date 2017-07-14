import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../auth/auth.dart';
import '../data/types.dart';
import '../i18n/strings.dart';
import '../widget/drawer.dart';
import '../widget/month_picker.dart';

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
  var _counter = 0;

  final _ref = FirebaseDatabase.instance.reference();
  StreamSubscription<Event> _counterSubscr;
  StreamSubscription<Event> _messageSubscr;

  @override
  void initState() {
    super.initState();

    final _counterRef = _ref.child(kRefCounter);
    final _messageRef = _ref.child(kRefMessages);

    _counterRef.keepSynced(true);

    _counterSubscr = _counterRef.onValue.listen((Event event) {
      setState(() => _counter = event.snapshot.value ?? 0);
    });

    _messageSubscr = _messageRef.onValue.listen((Event event) {
      print('Child added : ${event.snapshot.value}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscr.cancel();
    _counterSubscr.cancel();
  }

  Future<Null> _selectMonth(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: _filterDate);
    if (picked == null) return;

    setState(() => _filterDate = picked);
  }

  Future<Null> _increment() async {
    await ensureLoggedIn();

    // TODO(jackson): This illustrates a case where transactions are needed
    final _counterRef = _ref.child(kRefCounter);
    final snapshot = await _counterRef.once();
    setState(() => _counter = (snapshot.value ?? 0) + 1);
    _counterRef.set(_counter);

    final _messageRef = _ref.child(kRefMessages);
    _messageRef.push().set(<String, String>{'Hello': 'World $_counter'});
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
           'Button tapped $_counter time${_counter == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.title,
          ),
          new Text('This includes all devices, ever.'),
        ]),
      ),
      new Flexible(child: new FirebaseAnimatedList(
        query: _ref.child(kRefMessages),
        reverse: true,
        sort: (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key),
        itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation) {
          return new SizeTransition(
            sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: new Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: new Text(snapshot.value.toString()),
            ),
          );
        },
      ))
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
