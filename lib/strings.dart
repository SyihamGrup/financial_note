/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'dart:async';

import 'package:financial_note/src/i18n/lang_messages_all.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

// Information about how this file relates to i18n/stock_messages_all.dart and
// how the i18n files were generated can be found in i18n/regenerate.md.

class Lang {

  final String _localeName;

  Lang(Locale locale) : _localeName = locale.toString();

  static Future<Lang> load(Locale locale) {
    return initializeMessages(locale.toString()).then((Null _) {
      return new Lang(locale);
    });
  }

  static Lang of(BuildContext context) {
    return Localizations.of<Lang>(context, Lang);
  }

  String title()          => Intl.message('Financial Note', locale: _localeName, name: 'title');
  String titleBill()      => Intl.message('Bills',          locale: _localeName, name: 'titleBill');
  String titleBudget()    => Intl.message('Budgets',        locale: _localeName, name: 'titleBudget');
  String titleSettings()  => Intl.message('Settings',       locale: _localeName, name: 'titleSettings');
  String titleSignIn()    => Intl.message('Sign In',        locale: _localeName, name: 'titleSignIn');

  String drawerHome()     => Intl.message('Home',                 locale: _localeName, name: 'drawerHome');
  String drawerBills()    => Intl.message('Bills',                locale: _localeName, name: 'drawerBills');
  String drawerBudgets()  => Intl.message('Budgets',              locale: _localeName, name: 'drawerBudgets');
  String drawerSettings() => Intl.message('Settings',             locale: _localeName, name: 'drawerSettings');
  String drawerHelp()     => Intl.message('Help & Feedback',      locale: _localeName, name: 'drawerHelp');
  String drawerAbout()    => Intl.message('About Financial Note', locale: _localeName, name: 'drawerAbout');

  String menuSearch()  => Intl.message('Search', locale: _localeName, name: 'menuSearch');

  String btnOK()           => Intl.message('OK',                  locale: _localeName, name: 'btnOK');
  String btnCancel()       => Intl.message('Cancel',              locale: _localeName, name: 'btnCancel');
  String btnSignInGoogle() => Intl.message('Sign In With Google', locale: _localeName, name: 'btnSignInGoogle');
  String btnAdd()          => Intl.message('Add',                 locale: _localeName, name: 'btnAdd');
  String btnSave()         => Intl.message('Save',                locale: _localeName, name: 'btnSave');

  String prefUseDark() => Intl.message('Use Dark Theme', locale: _localeName, name: 'prefUseDark');

  String titleOpeningBalance() => Intl.message('Opening Balance', locale: _localeName, name: 'titleOpeningBalance');
  String titleAddTransaction() => Intl.message('Add Transaction', locale: _localeName, name: 'titleAddTransaction');

  String msgEmptyData()   => Intl.message('Tidak ada data', locale: _localeName, name: 'msgEmptyData');
  String msgLoading()     => Intl.message('Loading…',       locale: _localeName, name: 'msgLoading');

  String text() => Intl.message('', locale: _localeName, name: 'text');
}
