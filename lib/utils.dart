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
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  return 0.0;
}

/// Parse integer from dynamic variable.
int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  return 0;
}

/// Parse DateTime from dynamic variable.
DateTime parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  return null;
}

/// Parse String from dynamic value.
String parseString(dynamic value) {
  return value?.toString();
}

/// Parse bool from dynamic value.
bool parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String && value.toLowerCase() == 'true') return true;
  if (value is num && value > 0) return true;
  return false;
}

/// Get value dari Map, return def jika key missing pada map.
dynamic mapValue(Map map, String key, {dynamic def}) {
  if (map == null || !map.containsKey(key)) return def;
  return map[key];
}
