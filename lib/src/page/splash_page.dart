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

    getBook().then((book) {
      if (book == null) {
        Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
      } else {
        var routeName = routeWithParams(HomePage.kRouteName, <String, String>{'bookId': book.id});
        Navigator.pushReplacementNamed(context, routeName);
      }
    }).catchError((e) {
      setState(() => _subtitle = e.message);
    });
  }

  Future<Book> getBook() async {
    var user = await ensureLoggedIn();
    if (user == null) return null;

    var book = await Book.getDefault(user.uid);

    final ref = db.reference();
    ref.child(Book.kNodeName).child(user.uid).keepSynced(true);
    ref.child(Budget.kNodeName).child(book.id).keepSynced(true);
    ref.child(Bill.kNodeName).child(book.id).keepSynced(true);
    ref.child(Balance.kNodeName).child(book.id).keepSynced(true);
    ref.child(Transaction.kNodeName).child(book.id).keepSynced(true);

    return book;
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
