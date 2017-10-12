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
  static const kRouteName = '/home-bills';

  final String bookId;

  const HomePageBill({@required this.bookId}) : assert(bookId != null);

  @override
  State<StatefulWidget> createState() => new _HomePageBillState();
}

class _HomePageBillState extends State<HomePageBill> {

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}

class AppBarBill extends StatelessWidget implements PreferredSizeWidget {
  final Size preferredSize;

  AppBarBill() : preferredSize = new Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return new AppBar(title: new Text(Lang.of(context).titleBill()));
  }
}
