/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

library utils;

/// Parse double from dynamic variable.
double parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  return 0.0;
}

/// Parse integer from dynamic variable.
int parseInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  return 0;
}

dynamic mapValue(Map map, String key, {dynamic def}) {
  if (!map.containsKey(key)) return def;
  return map[key];
}
