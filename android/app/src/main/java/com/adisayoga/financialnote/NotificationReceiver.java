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
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.support.v4.content.WakefulBroadcastReceiver;
import android.util.Log;

import java.util.Date;
import java.util.List;

public class NotificationReceiver extends WakefulBroadcastReceiver {
  static final String TAG = "NotificationReceiver";

  @Override
  public void onReceive(Context context, Intent intent) {
    Log.d(TAG, "On receive scheduled notification");
    final SQLiteDatabase db = new DatabaseHelper(context).getWritableDatabase();
    showNotification(context, db);
    NotificationEntry.removeOldNotifications(db);

    final Date nextDate = NotificationEntry.getNextNotificationDate(db);
    if (nextDate != null) {
      Log.d(TAG, "Next notification: " + nextDate.toString());
      Util.scheduleNotification(context, nextDate);
    }

    completeWakefulIntent(intent);
  }

  private void showNotification(Context context, SQLiteDatabase db) {
    final List<NotificationEntry> notifications = NotificationEntry.getNotifications(db);
    if (notifications == null || notifications.size() == 0) return;

    int id = 1;
    for (final NotificationEntry notification : notifications) {
      Util.showNotification(context, id++, notification);
    }
  }
}
