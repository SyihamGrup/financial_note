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

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;

import java.util.List;

public class BootReceiver extends BroadcastReceiver {

  @Override
  public void onReceive(Context context, Intent intent) {
    if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
      final SQLiteDatabase db = new DatabaseHelper(context).getReadableDatabase();
      final List<NotificationEntry> notifications = NotificationEntry.getNotifications(db);
      if (notifications == null || notifications.size() == 0) return;
      Util.scheduleNotification(context, notifications.get(0).date);
    }
  }
}
