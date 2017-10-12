
/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library page;

import 'dart:async';

import 'package:financial_note/auth.dart';
import 'package:financial_note/config.dart';
import 'package:financial_note/data.dart';
import 'package:financial_note/globals.dart' as globals;
import 'package:financial_note/routes.dart';
import 'package:financial_note/strings.dart';
import 'package:financial_note/widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'src/page/budget_page.dart';
part 'src/page/home_page.dart';
part 'src/page/home_page_bill.dart';
part 'src/page/home_page_budget.dart';
part 'src/page/home_page_transaction.dart';
part 'src/page/settings_page.dart';
part 'src/page/sign_in_page.dart';
part 'src/page/splash_page.dart';
part 'src/page/transaction_page.dart';

const kIconHome = const Icon(Icons.home);
const kIconBill = const Icon(Icons.monetization_on);
const kIconBudget = const Icon(Icons.insert_chart);

const kIconBack = const Icon(Icons.arrow_back);
const kIconClose = const Icon(Icons.close);
const kIconAdd = const Icon(Icons.add);
const kIconSearch = const Icon(Icons.search);
const kIconEdit = const Icon(Icons.edit);
const kIconDelete = const Icon(Icons.delete);

Widget buildListProgress(Listenable animation, {isLoading: false}) {
  return new AnimatedBuilder(animation: animation, builder: (context, child) {
    if (!isLoading) return new Container();
    return const SizedBox(height: 2.0, child: const LinearProgressIndicator());
  });
}
