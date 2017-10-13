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

  String prefUseDark() => Intl.message('Use Dark Theme', locale: _localeName, name: 'prefUseDark');

  String title()          => Intl.message('Financial Note', locale: _localeName, name: 'title');
  String titleBill()      => Intl.message('Bills',          locale: _localeName, name: 'titleBill');
  String titleBudget()    => Intl.message('Budgets',        locale: _localeName, name: 'titleBudget');
  String titleSettings()  => Intl.message('Settings',       locale: _localeName, name: 'titleSettings');
  String titleSignIn()    => Intl.message('Sign In',        locale: _localeName, name: 'titleSignIn');

  String titleOpeningBalance() => Intl.message('Opening Balance', locale: _localeName, name: 'titleOpeningBalance');
  String titleAddTransaction() => Intl.message('Add Transaction', locale: _localeName, name: 'titleAddTransaction');
  String titleAddBudget()      => Intl.message('Add Budget',      locale: _localeName, name: 'titleAddBudget');

  String drawerHome()     => Intl.message('Home',                 locale: _localeName, name: 'drawerHome');
  String drawerBills()    => Intl.message('Bills',                locale: _localeName, name: 'drawerBills');
  String drawerBudgets()  => Intl.message('Budgets',              locale: _localeName, name: 'drawerBudgets');
  String drawerSettings() => Intl.message('Settings',             locale: _localeName, name: 'drawerSettings');
  String drawerHelp()     => Intl.message('Help & Feedback',      locale: _localeName, name: 'drawerHelp');
  String drawerAbout()    => Intl.message('About Financial Note', locale: _localeName, name: 'drawerAbout');

  String menuSearch()  => Intl.message('Search', locale: _localeName, name: 'menuSearch');
  String menuEdit()    => Intl.message('Edit',   locale: _localeName, name: 'menuEdit');
  String menuDelete()  => Intl.message('Delete', locale: _localeName, name: 'menuDelete');

  String btnOK()           => Intl.message('OK',                  locale: _localeName, name: 'btnOK');
  String btnCancel()       => Intl.message('Cancel',              locale: _localeName, name: 'btnCancel');
  String btnYes()          => Intl.message('Yes',                 locale: _localeName, name: 'btnYes');
  String btnNo()           => Intl.message('No',                  locale: _localeName, name: 'btnNo');
  String btnSignInGoogle() => Intl.message('Sign In With Google', locale: _localeName, name: 'btnSignInGoogle');
  String btnAdd()          => Intl.message('Add',                 locale: _localeName, name: 'btnAdd');
  String btnSave()         => Intl.message('Save',                locale: _localeName, name: 'btnSave');

  String lblIncome()       => Intl.message('Income',              locale: _localeName, name: 'lblIncome');
  String lblExpense()      => Intl.message('Expense',             locale: _localeName, name: 'lblExpense');
  String lblBudget()       => Intl.message('Budget',              locale: _localeName, name: 'lblBudget');
  String lblBill()         => Intl.message('Bill',                locale: _localeName, name: 'lblBill');
  String lblBillPeriod()   => Intl.message('Period',              locale: _localeName, name: 'lblBillPeriod');
  String lblTitle()        => Intl.message('Title',               locale: _localeName, name: 'lblTitle');
  String lblDate()         => Intl.message('Date',                locale: _localeName, name: 'lblDate');
  String lblValue()        => Intl.message('Value',               locale: _localeName, name: 'lblValue');

  String msgSignInRequired() => Intl.message('Sign in required',                               locale: _localeName, name: 'msgSignInRequired');
  String msgWait()           => Intl.message('Please Wait',                                    locale: _localeName, name: 'msgWait');
  String msgSaved()          => Intl.message('Data saved',                                     locale: _localeName, name: 'msgSaved');
  String msgEmptyData()      => Intl.message('Tidak ada data',                                 locale: _localeName, name: 'msgEmptyData');
  String msgLoading()        => Intl.message('Loading…',                                       locale: _localeName, name: 'msgLoading');
  String msgFormHasError()   => Intl.message('This form has errors',                           locale: _localeName, name: 'msgFormHasError');
  String msgFormError()      => Intl.message('Please fix the errors in red before submitting', locale: _localeName, name: 'msgFixFormError');
  String msgFieldRequired()  => Intl.message('This field is required',                         locale: _localeName, name: 'msgFieldRequired');

}
