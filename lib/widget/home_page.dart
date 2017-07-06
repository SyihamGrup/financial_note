import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/types.dart';
import '../widget/drawer.dart';

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
  DateFormat headerDateFormatter = new DateFormat.yMMMM();

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(title: new InkWell(
      onTap: () => null,
      child: new Container(
        height: kToolbarHeight,
        child: new Row(children: <Widget>[
          new Text(headerDateFormatter.format(filterDate),
              style: Theme.of(context).primaryTextTheme.title),
          new Icon(Icons.arrow_drop_down),
        ]),
      ),
    ));
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
