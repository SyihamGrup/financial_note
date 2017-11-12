/*
 * Copyright (c) 2017. All rights reserved.
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential.
 *
 * Written by:
 *   - Adi Sayoga <adisayoga@gmail.com>
 */

package com.adisayoga.financialnote;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.provider.BaseColumns;
import android.util.Log;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

class NotificationEntry implements BaseColumns {
  private static final String TAG = "NotificationEntry";
  static final String TABLE = "notifications";

  static final String DATE = "date";
  static final String TICKER = "ticker";
  static final String TITLE = "title";
  static final String CONTENT = "content";
  static final String ACTION = "action_name";
  static final String REF_ID = "ref_id";

  long _id;
  Date date;
  String ticker;
  String title;
  String content;
  String action;
  String refId;

  NotificationEntry(long _id,
                    Date date, String ticker, String title, String content,
                    String action, String refId) {
    this._id = _id;
    this.date = date;
    this.ticker = ticker;
    this.title = title;
    this.content = content;
    this.action = action;
    this.refId = refId;
  }

  static List<NotificationEntry> getNotifications(SQLiteDatabase db) {
    List<NotificationEntry> items = new ArrayList<>();
    final Cursor c = db.query(
      TABLE, new String[]{_ID, DATE, TICKER, TITLE, CONTENT, ACTION, REF_ID},
      DATE + " <= ?", new String[] {DatabaseHelper.formatDate(new Date())},
      null,null, DATE
    );
    while (c.moveToNext()) {
      items.add(new NotificationEntry(
        c.getLong(0),
        DatabaseHelper.parseDate(c.getString(1)),
        c.getString(2),
        c.getString(3),
        c.getString(4),
        c.getString(5),
        c.getString(6)
      ));
    }
    c.close();
    return items;
  }

  static Date getNextNotificationDate(SQLiteDatabase db) {
    Date nextDate = null;
    final Cursor c = db.query(
      TABLE, new String[]{DATE}, DATE + " > ?", new String[]{DatabaseHelper.formatDate(new Date())},
      null, null, DATE, "1"
    );
    if (c.moveToFirst()) nextDate = DatabaseHelper.parseDate(c.getString(0));
    c.close();
    return nextDate;
  }

  static void removeOldNotifications(SQLiteDatabase db) {
    final String date = DatabaseHelper.formatDate(new Date());
    try {
      db.delete(TABLE, DATE + " IS NULL OR " + DATE + " <= ?", new String[]{date});
    } catch (Exception e) {
      Log.e(TAG, e.getMessage());
    }
  }

  void save(SQLiteDatabase db) {
    final ContentValues values = new ContentValues();
    values.put(DATE, DatabaseHelper.formatDate(date));
    values.put(TICKER, ticker);
    values.put(TITLE, title);
    values.put(CONTENT, content);
    values.put(ACTION, action);
    values.put(REF_ID, refId);

    try {
      if (DatabaseHelper.isExists(db, TABLE, REF_ID, refId)) {
        db.update(TABLE, values, REF_ID + " = ?", new String[]{refId});
      } else {
        db.insert(TABLE, null, values);
      }
    } catch (Exception e) {
      Log.e(TAG, e.getMessage());
    }
  }

  @Override
  public String toString() {
    return _ID     + ": " + _id + ", " +
           DATE    + ": " + date.toString() + ", " +
           TICKER  + ": " + ticker + ", " +
           TITLE   + ": " + title + ", " +
           CONTENT + ": " + content + ", " +
           ACTION  + ": " + action + ", " +
           REF_ID  + ": " + refId;
  }
}
