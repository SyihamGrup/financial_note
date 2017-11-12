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

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import java.util.Date;

class Util {
  static final String TAG = "Util";

  static void showNotification(Context context, int id, NotificationEntry data) {
    final NotificationManager manager = (NotificationManager)
                                        context.getSystemService(Context.NOTIFICATION_SERVICE);
    if (manager == null) return;

    final Intent intent = new Intent(context, MainActivity.class);
    intent.putExtra("action", data.action);
    intent.putExtra("ref_id", data.refId);
    intent.putExtra("click_action", "FLUTTER_NOTIFICATION_CLICK");

    final NotificationCompat.Builder builder = new NotificationCompat.Builder(context);
    builder.setContentIntent(PendingIntent.getActivity(context, 0, intent, 0));
    builder.setSmallIcon(R.mipmap.ic_launcher);
    builder.setTicker(data.ticker);
    builder.setContentTitle(data.title);
    builder.setContentText(data.content);

    final Notification notification = builder.build();
    notification.vibrate = new long[]{150, 300, 150, 400};
    notification.flags = Notification.FLAG_AUTO_CANCEL;

    manager.notify(id, notification);
  }

  static void scheduleNotification(Context context, Date date) {
    final AlarmManager alarm = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
    if (alarm == null) return;
    Log.d(TAG, "Scheduling notification on " + date.toString());

    final Intent intent = new Intent(context, NotificationReceiver.class);
    final PendingIntent pendingIntent = PendingIntent.getBroadcast(
      context, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT
    );

    alarm.setExact(AlarmManager.RTC_WAKEUP, date.getTime(), pendingIntent);
  }

}
