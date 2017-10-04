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

    ensureLoggedIn().then((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
      } else {
        Navigator.pushReplacementNamed(context, HomePage.kRouteName);
      }
    }).catchError((e) {
      setState(() => _subtitle = e.toString());
    });
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
            new Text(_subtitle, style: theme.primaryTextTheme.body1),
          ]
        )),
      ),
    );
  }
}
