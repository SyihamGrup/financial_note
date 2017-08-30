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

Future<FirebaseUser> showLoginIfUnauthenticated(BuildContext context) async {
  final user = await ensureLoggedIn();
  if (user == null) {
    Navigator.pushReplacementNamed(context, SignInPage.kRouteName);
    return null;
  }
  return user;
}
