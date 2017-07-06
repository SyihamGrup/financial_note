import 'package:flutter/material.dart';

import '../data/types.dart';
import '../strings.dart';
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

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(title: new Text(Lang.of(context).title()));
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
