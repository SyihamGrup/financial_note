/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Get opening balance
exports.getOpeningBalance = functions.https.onRequest((req, res) => {
  const bookId = req.query.bookId;
  const date = req.query.date;

  admin.database().ref('/balances/' + bookId).orderByChild('date').endAt(date).once('value', snapshot => {
    const data = snapshot.val();
    if (typeof(data) !== 'object') {
      res.json({balance: 0});
      return;
    }

    let total = 0;
    for (let key in data) {
      total += data[key].value || 0;
    }
    res.json({balance: total});
  });
});
