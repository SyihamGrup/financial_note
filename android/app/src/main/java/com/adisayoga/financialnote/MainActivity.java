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

import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  static final String TAG = "MainActivity";
  static final String NOTIFICATION_CHANNEL = "financialnote.adisayoga.com/notification";
  static final String SCHEDULE_NOTIFICATION = "schedule_notification";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), NOTIFICATION_CHANNEL).setMethodCallHandler(
      new MethodChannel.MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, MethodChannel.Result result) {
          Log.d(TAG, "Notification channel: method=" + call.method);
          if (call.method.equals(SCHEDULE_NOTIFICATION)) {
            scheduleNotification(call);
            result.success(true);
          } else {
            result.notImplemented();
          }
        }
      });
  }

  private void scheduleNotification(MethodCall call) {
    final NotificationEntry notification = new NotificationEntry(
        0,
        DatabaseHelper.parseDate((String) call.argument("date")),
        (String) call.argument("ticker"),
        (String) call.argument("title"),
        (String) call.argument("content"),
        (String) call.argument("action"),
        (String) call.argument("ref_id")
    );
    Log.d(TAG, "Notification data: " + notification.toString());

    if (notification.date == null) return;
    final SQLiteDatabase db = new DatabaseHelper(this).getWritableDatabase();
    notification.save(db);
    Util.scheduleNotification(this, notification.date);
  }
}
