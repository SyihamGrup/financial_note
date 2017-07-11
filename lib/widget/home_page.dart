import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/types.dart';
import '../strings.dart';
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
  DateTime filterDate = new DateTime.now();

  Future<Null> _selectMonth(BuildContext context) async {
    final DateTime picked = await showMonthPicker(context: context, initialDate: filterDate);
    if (picked != null) {
      setState(() => filterDate = picked);
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(
      title: new InkWell(
        onTap: () => _selectMonth(context),
        child: new Container(
          height: kToolbarHeight,
          child: new Row(children: <Widget>[
            new Text(new DateFormat.yMMM().format(filterDate),
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
    return new Container(
      margin: const EdgeInsets.all(16.0),
      child: const Text('Home page...'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(context),
      drawer: new AppDrawer(),
      body: _buildBody(context),
    );
  }
}
