import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

final _db = FirebaseDatabase.instance.reference();

// Tambah anggaran keuangan


class Counter {
  static final name = 'counter';
}

class Message {
  static final name = 'messages';
}

class TransactionGroup {
  static final name = 'transactions_groups';

  String id;
  DateTime dueDate;
  DateTime lastPaid;
  double totalValue;
  double paidValue;

  final transactions = <String, bool>{};
}

class Transaction {
  static final name = 'transactions';

  String _userId;

  String id;
  String groupId;
  String budgetId;
  String period;
  DateTime dueDate;
  DateTime paidDate;
  double value;
  double paidValue;
  String note;

  static final _cache = <String, Transaction>{};

  factory Transaction(String userId) {
    if (_cache.containsKey(userId)) return _cache[userId];

    final instance = new Transaction._internal(userId);
    _cache[userId] = instance;
    return instance;
  }

  Transaction._internal(this._userId);

  Future<Null> add(Transaction v) async {

    return null;
  }
}

class Budget {
  String id;
  final transactions = <String, bool>{};
}

class Balance {
  static final name = 'balances';

  String _userId;

  static final _cache = <String, Balance>{};

  factory Balance(String userId) {
    if (_cache.containsKey(userId)) return _cache[userId];

    final instance = new Balance._internal(userId);
    _cache[userId] = instance;
    return instance;
  }

  Balance._internal(this._userId);

  double get(DateTime period) {
    return 0.0;
  }
}
