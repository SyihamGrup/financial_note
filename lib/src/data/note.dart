/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

import 'package:financial_note/utils.dart';
import 'package:firebase_database/firebase_database.dart';

class Note {
  static const kNodeName = 'notes';

  String id;
  String title;
  String note;
  DateTime reminder;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    this.id,
    this.title,
    this.note,
    this.reminder,
    this.createdAt,
    this.updatedAt,
  });

  Note.fromJson(this.id, Map<String, dynamic> json)
    : title     = parseString(mapValue(json, 'title')),
      note      = parseString(mapValue(json, 'note')),
      reminder  = parseDate(mapValue(json, 'reminder')),
      createdAt = parseDate(mapValue(json, 'createdAt')),
      updatedAt = parseDate(mapValue(json, 'updatedAt'));

  Note.fromSnapshot(DataSnapshot snapshot)
    : id        = snapshot.key,
      title     = parseString(mapValue(snapshot.value, 'title')),
      note      = parseString(mapValue(snapshot.value, 'note')),
      reminder  = parseDate(mapValue(snapshot.value, 'reminder')),
      createdAt = parseDate(mapValue(snapshot.value, 'createdAt')),
      updatedAt = parseDate(mapValue(snapshot.value, 'updatedAt'));

  static DatabaseReference ref(String bookId) {
    return FirebaseDatabase.instance.reference().child(kNodeName).child(bookId);
  }

  Map<String, dynamic> toJson({showId: false}) {
    final json = <String, dynamic>{
      'id'        : id,
      'title'     : title,
      'note'      : note,
      'reminder'  : reminder?.toIso8601String(),
      'createdAt' : createdAt?.toIso8601String(),
      'updatedAt' : updatedAt?.toIso8601String(),
    };
    if (!showId) json.remove('id');
    return json;
  }

  Note copyWith({
    String id,
    String title,
    String note,
    DateTime reminder,
    DateTime createdAt,
    DateTime updatedAt,
  }) {
    return new Note(
      id        : id        ?? this.id,
      title     : title     ?? this.title,
      note      : note      ?? this.note,
      reminder  : reminder  ?? this.reminder,
      createdAt : createdAt ?? this.createdAt,
      updatedAt : updatedAt ?? this.updatedAt,
    );
  }

}
