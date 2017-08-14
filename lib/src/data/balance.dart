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

class Balance {
  static const kNodeName = 'balances';

  static DatabaseReference ref(String bookId) {
    return _db.child(kNodeName).child(bookId);
  }

  static Future<double> get(String bookId, int year, int month) async {
    final snap = await ref(bookId).child("$year$month").once();
    return parseDouble(snap.value);
  }

  static Future<Null> calculate(String bookId, int year, int month) async {
    final httpClient = createHttpClient();

    final params = <String, dynamic>{
      'bookId' : bookId,
      'year'   : year,
      'month'  : month,
    };
    final response = await httpClient.get(firebaseUri(kCalcOpeningBalancePath, params));

    Map<String, dynamic> json = JSON.decode(response.body);
    return json.containsKey('balance') ? parseDouble(json['balance']) : 0.0;
  }

}
