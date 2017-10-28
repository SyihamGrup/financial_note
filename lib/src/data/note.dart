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

  static Future<Note> get(String bookId, String id) async {
    final snap = await getNode(bookId).child(id).once();
    if (snap.value == null) return null;
    return new Note.fromSnapshot(snap);
  }

  Future<Null> save(String bookId) async {
    final node = getNode(bookId);
    final ref = id != null ? node.child(id) : node.push();
    await ref.set(toJson());
    id = ref.key;
  }

  static Future<Null> remove(String bookId, String id) async {
    final node = getNode(bookId);
    await node.child(id).remove();
  }

  static DatabaseReference getNode(String bookId) {
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
}
