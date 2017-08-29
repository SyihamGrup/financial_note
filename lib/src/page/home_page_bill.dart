/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of page;

class HomePageBill extends StatefulWidget {
  static const kRouteName = '/home/bills';

  final Config config;

  const HomePageBill(this.config);

  @override
  State<StatefulWidget> createState() => new _HomePageBillState();
}

class _HomePageBillState extends State<HomePageBill> {

  Widget _buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text(Lang.of(context).titleBill()),
    );
  }

  Widget _buildBody() {
    return new Container();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(context),
      drawer: new AppDrawer(selectedRoute: HomePageBill.kRouteName),
      body: _buildBody(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => null,
        tooltip: Lang.of(context).btnAdd(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
