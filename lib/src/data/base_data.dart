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

abstract class Data {
  get id;

  Future<Null> save();

  Future<Null> remove();

  Map<String, dynamic> toJson({showId: false});
}
