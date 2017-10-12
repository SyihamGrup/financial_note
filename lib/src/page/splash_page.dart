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

class SplashPage extends StatefulWidget {
  static const kRouteName = '/splash';

  const SplashPage();

  @override
  State<StatefulWidget> createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _subtitle;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<Null> _init() async {
    try {
      await ensureLoggedIn();
      if (auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
        return;
      }

      final book = await Book.getDefault(auth.currentUser.uid);
      assert(book != null);
      globals.currentBook = book;

      final ref = db.reference();
      ref.child(Book.kNodeName).child(auth.currentUser.uid).keepSynced(true);
      ref.child(Budget.kNodeName).child(book.id).keepSynced(true);
      ref.child(Bill.kNodeName).child(book.id).keepSynced(true);
      ref.child(Balance.kNodeName).child(book.id).keepSynced(true);
      ref.child(Transaction.kNodeName).child(book.id).keepSynced(true);

      final routeName = routeWithParams(HomePage.kRouteName, <String, String>{'bookId': book.id});
      Navigator.pushReplacementNamed(context, routeName);

    } catch (e) {
      setState(() => _subtitle = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _subtitle = _subtitle == null ? Lang.of(context).msgLoading() : _subtitle;

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: theme.primaryColor),
        child: new Center(child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Text(Lang.of(context).title(), style: theme.primaryTextTheme.display1),
            new Text(_subtitle,
              textAlign: TextAlign.center,
              style: theme.primaryTextTheme.body1.copyWith(color: Colors.white70)
            ),
          ]
        )),
      ),
    );
  }
}
