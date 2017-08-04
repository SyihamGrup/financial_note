/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

part of data;

class TransactionGroup {
  static const kNodeName = 'transactions_groups';

  String id;
  DateTime dueDate;
  DateTime lastPaid;
  double totalValue;
  double paidValue;

  final transactions = <String, bool>{};

  TransactionGroup({
    this.id,
    this.dueDate,
    this.lastPaid,
    this.totalValue,
    this.paidValue
  });

  static DatabaseReference ref(String bookId) {
    return _db.child(kNodeName).child(bookId);
  }

//  TransactionGroup.fromJson(Map json)
//      : id = json['id'],
//        dueDate = json['dueDate'],
//        lastPaid = json['lastPaid'],
//        totalValue = json['totalValue'],
//        paidValue = json['paidValue'];
//
//  Map<String, dynamic> toJson() {
//    return <String, dynamic>{
//      'id': id,
//      'dueDate': dueDate,
//      'lastPaid': lastPaid,
//      'totalValue': totalValue,
//      'paidValue': paidValue
//    };
//  }
}

class Transaction {
  static const kNodeName = 'transactions';

  final String id;
  final String groupId;
  final String budgetId;
  final String descr;
  final String period;
  final DateTime date;
  final double value;
  final double balance;
  final String note;

  const Transaction({
    this.id,
    this.groupId,
    this.budgetId,
    this.descr,
    this.period,
    this.date,
    this.value : 0.0,
    this.balance: 0.0,
    this.note,
  });

  Transaction.fromJson(this.id, Map<String, dynamic> json)
    : groupId   = json != null && json.containsKey('groupId')  ? json['groupId']              : null,
      budgetId  = json != null && json.containsKey('budgetId') ? json['budgetId']             : null,
      descr     = json != null && json.containsKey('descr')    ? json['descr']                : null,
      period    = json != null && json.containsKey('period')   ? json['period']               : null,
      date      = json != null && json.containsKey('date')     ? DateTime.parse(json['date']) : null,
      value     = json != null && json.containsKey('value')    ? parseDouble(json['value'])   : 0.0,
      balance   = json != null && json.containsKey('balance')  ? parseDouble(json['balance']) : 0.0,
      note      = json != null && json.containsKey('note')     ? json['note']                 : null;

  static DatabaseReference ref(String bookId) {
    return _db.child(kNodeName).child(bookId);
  }

  static Future<List<Transaction>> list(
      BuildContext context, String bookId, DateTime dateStart, DateTime dateEnd
  ) async {
    var formatter = new DateFormat('yyyy-MM-dd');
    var ret = new List<Transaction>();

    var openingBalance = await getOpeningBalance(bookId, dateEnd);
    ret.add(new Transaction(
      descr: Lang.of(context).titleOpeningBalance(),
      balance: openingBalance
    ));

    var snap = await ref(bookId)
        .orderByChild('paidDate')
        .startAt(formatter.format(dateStart), key: 'paidDate')
        .endAt(formatter.format(dateEnd), key: 'paidDate')
        .once();

    if (snap.value == null) return ret;

    var balance = openingBalance;
    Map<String, Map<String, dynamic>> items = snap.value;
    items.forEach((key, item) {
      balance += item.containsKey('value') ? parseDouble(item['value']) : 0.0;
      item['balance'] = balance;
      ret.add(new Transaction.fromJson(key, item));
    });

    return ret;
  }

  static Future<double> getOpeningBalance(String bookId, DateTime dateEnd) async {
    var httpClient = createHttpClient();

    final params = <String, String>{
      'bookId': bookId,
      'date':   new DateFormat('yyyy-MM-dd').format(dateEnd),
    };
    final response = await httpClient.get(firebaseUri(kOpeningBalancePath, params));

    Map<String, dynamic> json = JSON.decode(response.body);
    return json.containsKey('balance') ? parseDouble(json['balance']) : 0.0;
  }

  Future<Null> add(Transaction v) async {

    return null;
  }
}
