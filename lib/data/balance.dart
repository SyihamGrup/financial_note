// Copyright (c) 2017. All rights reserved.
//
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//
// Written by:
//   - Adi Sayoga <adisayoga@gmail.com>

class Balance {
  static const nodeName = 'balances';

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
