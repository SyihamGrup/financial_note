/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

// Wrappers for strings that are shown in the UI.
// The strings can be translated for different locales using the Dart intl package.
//
// Locale-specific values for the strings live in the i18n/*.arb files.
//
// To generate the lang_messages_*.dart files from the ARB files, run:
//   pub run intl:generate_from_arb \
//     --output-dir=src/lib/i18n --generated-file-prefix=lang_ --no-use-deferred-loading \
//     strings.dart src/lib/i18n/lang_*.arb

class Lang extends LocaleQueryData {

  static Lang of(BuildContext context) {
    return LocaleQuery.of(context);
  }

  static final instance = new Lang();

  String title()          => Intl.message('Financial Note', name: 'title');
  String titleSettings()  => Intl.message('Settings',       name: 'titleSettings');
  String titleSignIn()    => Intl.message('Sign In',       name: 'titleSignIn');

  String drawerHome()     => Intl.message('Home',                 name: 'drawerHome');
  String drawerSettings() => Intl.message('Settings',             name: 'drawerSettings');
  String drawerHelp()     => Intl.message('Help & Feedback',      name: 'drawerHelp');
  String drawerAbout()    => Intl.message('About Financial Note', name: 'drawerAbout');

  String menuSearch()  => Intl.message('Search', name: 'menuSearch');

  String btnOK()           => Intl.message('OK', name: 'btnOK');
  String btnCancel()       => Intl.message('Cancel', name: 'btnCancel');
  String btnSignInGoogle() => Intl.message('Sign In With Google', name: 'btnSignInGoogle');

  String prefUseDark() => Intl.message('Use Dark Theme', name: 'prefUseDark');

  String titleOpeningBalance() => Intl.message('Opening Balance', name: 'titleOpeningBalance');

  String msgEmptyData()   => Intl.message('Tidak ada data', name: 'msgEmptyData');
  String msgLoading()     => Intl.message('Loading…', name: 'msgLoading');
}
