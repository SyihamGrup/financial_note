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

class SignInPage extends StatelessWidget {
  static const kRouteName = '/sign-in';

  const SignInPage();

  Future<Null> signIn(BuildContext context) async {
    final google = await signInWithGoogle();
    if (google == null) return;
    analytics.logLogin();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kPrefSignInMethod, kPrefSignInGoogle);
    final c = await google.authentication;
    await auth.signInWithGoogle(idToken: c.idToken, accessToken: c.accessToken);

    Navigator.pushReplacementNamed(context, HomePage.kRouteName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: theme.primaryColor),
        padding: new EdgeInsets.fromLTRB(32.0, MediaQuery.of(context).padding.top + 16.0, 32.0, 16.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            new Text(Lang.of(context).title(),
                style: theme.primaryTextTheme.display1),
            new Container(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: new Text(Lang.of(context).msgSignInRequired(),
                         style: theme.primaryTextTheme.body1),
            ),
            new Row(children: <Widget>[
              new Expanded(child: new RaisedButton(
                onPressed: () => signIn(context),
                child: new Text(Lang.of(context).btnSignInGoogle(),
                           style: theme.accentTextTheme.button),
                color: theme.accentColor,
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
