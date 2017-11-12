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

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class DatabaseHelper extends SQLiteOpenHelper {
  private static final int DB_VERSION = 1;
  private static final String DB_NAME = "FinancialNote.db";

  DatabaseHelper(Context context) {
    super(context, DB_NAME, null, DB_VERSION);
  }

  @Override
  public void onCreate(SQLiteDatabase db) {
    db.execSQL(
      "CREATE TABLE " + NotificationEntry.TABLE + " (" +
        NotificationEntry._ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
        NotificationEntry.DATE + " TEXT, " +
        NotificationEntry.TICKER + " TEXT, " +
        NotificationEntry.TITLE + " TEXT, " +
        NotificationEntry.CONTENT + " TEXT, " +
        NotificationEntry.ACTION + " TEXT, " +
        NotificationEntry.REF_ID + " TEXT " +
      ")"
    );
  }

  @Override
  public void onUpgrade(SQLiteDatabase db, int oldVer, int newVer) {
    db.execSQL("DROP TABLE IF EXISTS " + NotificationEntry.TABLE);
    onCreate(db);
  }

  public void onDowngrade(SQLiteDatabase db, int oldVer, int newVer) {
    onUpgrade(db, oldVer, newVer);
  }

  static boolean isExists(SQLiteDatabase db, String table, String column, String value) {
    final Cursor c = db.query(table, new String[]{column},
      column + " = ?", new String[]{value},
      null, null, null, "1");
    final boolean exists = c.moveToFirst();
    c.close();
    return exists;
  }

  static String formatDate(Date date) {
    return getDateFormatter().format(date);
  }

  static Date parseDate(String sDate) {
    if (sDate == null) return null;
    try {
      return getDateFormatter().parse(sDate);
    } catch (ParseException e) {
      return null;
    }
  }

  private static DateFormat getDateFormatter() {
    return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
  }
}
