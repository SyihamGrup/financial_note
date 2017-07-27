// Copyright (c) 2017. All rights reserved.
//
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//
// Written by:
//   - Adi Sayoga <adisayoga@gmail.com>

import 'package:firebase_database/firebase_database.dart';

final _db = FirebaseDatabase.instance.reference();

class Book {
  static const nodeName = 'books';

  String uid;

  String name;
  String description;

  static Book of(String uid) {
    return new Book(uid: uid);
  }

  Book({this.uid, this.name, this.description});

  static DatabaseReference get ref {
    return _db.child(nodeName);
  }

  Book.fromJson(uid, Map<String, dynamic> json)
      : this.uid = uid,
        this.name = json['name'],
        this.description = json['description'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
    };
  }

}
