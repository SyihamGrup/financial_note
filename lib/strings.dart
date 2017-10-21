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

  String _(String name, String message) {
    return Intl.message(message, name: name, locale: _localeName);
  }

  String prefUseDark() => _('prefUseDark', 'Use Dark Theme');

  String title()          => _('title',         'Financial Note');
  String titleBill()      => _('titleBill',     'Bills');
  String titleBudget()    => _('titleBudget',   'Budgets');
  String titleNote()      => _('titleNote',     'Notes');
  String titleSettings()  => _('titleSettings', 'Settings');
  String titleSignIn()    => _('titleSignIn',   'Sign In');

  String titleOpeningBalance()  => _('titleOpeningBalance',  'Opening Balance');
  String titleAddTransaction()  => _('titleAddTransaction',  'New Transaction');
  String titleEditTransaction() => _('titleEditTransaction', 'Edit Transaction');
  String titleAddBill()         => _('titleAddBill',         'New Bill');
  String titleEditBill()        => _('titleEditBill',        'Edit Bill');
  String titleAddBudget()       => _('titleAddBudget',       'New Budget');
  String titleEditBudget()      => _('titleEditBudget',      'Edit Budget');
  String titleAddNote()         => _('titleAddNote',         'New Note');
  String titleEditNote()        => _('titleEditNote',        'Edit Note');
  String titleConfirmation()    => _('titleConfirmation',    'Confirmation');
  String titleValidate()        => _('titleValidate',        'Validate');
  String titleLeave()           => _('titleLeave',           'Leave?');

  String drawerHome()     => _('drawerHome',     'Home');
  String drawerBills()    => _('drawerBills',    'Bills');
  String drawerBudgets()  => _('drawerBudgets',  'Budgets');
  String drawerNotes()    => _('drawerNotes',    'Notes');
  String drawerSettings() => _('drawerSettings', 'Settings');
  String drawerHelp()     => _('drawerHelp',     'Help & Feedback');
  String drawerAbout()    => _('drawerAbout',    'About Financial Note');

  String menuSearch()  => _('menuSearch', 'Search');
  String menuEdit()    => _('menuEdit',   'Edit');
  String menuDelete()  => _('menuDelete', 'Delete');

  String btnOK()           => _('btnOK',           'OK');
  String btnCancel()       => _('btnCancel',       'Cancel');
  String btnYes()          => _('btnYes',          'Yes');
  String btnNo()           => _('btnNo',           'No');
  String btnSignInGoogle() => _('btnSignInGoogle', 'Sign In With Google');
  String btnAdd()          => _('btnAdd',          'Add');
  String btnAddItem()      => _('btnAddItem',      'Add Item');
  String btnSave()         => _('btnSave',         'Save');

  String lblIncome()       => _('lblIncome',     'Income');
  String lblExpense()      => _('lblExpense',    'Expense');
  String lblBudget()       => _('lblBudget',     'Budget');
  String lblBill()         => _('lblBill',       'Bill');
  String lblBillPeriod()   => _('lblBillPeriod', 'Period');
  String lblTitle()        => _('lblTitle',      'Title');
  String lblDate()         => _('lblDate',       'Date');
  String lblValue()        => _('lblValue',      'Value');
  String lblTotal()        => _('lblTotal',      'Total');
  String lblSpent()        => _('lblSpent',      'Spent');
  String lblDescr()        => _('lblDescr',      'Description');
  String lblNote()         => _('lblNote',       'Note');
  String lblItem()         => _('lblItem',       'Item');
  String lblReminder()     => _('lblReminder',   'Reminder');

  String msgSignInRequired() => _('msgSignInRequired', 'Sign in required');
  String msgWait()           => _('msgWait',           'Please Wait');
  String msgSaving()         => _('msgSaving',         'Saving…');
  String msgSaved()          => _('msgSaved',          'Data saved');
  String msgEmptyData()      => _('msgEmptyData',      'No data');
  String msgLoading()        => _('msgLoading',        'Loading…');
  String msgFormHasError()   => _('msgFormHasError',   'This form has errors');
  String msgFormError()      => _('msgFixFormError',   'Please fix the errors in red before submitting');
  String msgFieldRequired()  => _('msgFieldRequired',  'This field is required');
  String msgConfirmLeave()   => _('msgConfirmLeave',   'Your data will be lost. Are you sure to leave this form?');
  String msgConfirmDelete()  => _('msgConfirmDelete',  'Are you sure to delete this item(s)?');
}
