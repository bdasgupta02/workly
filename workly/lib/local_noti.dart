import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/*
  Things to note:
  - Need to initialise local variable LocalNotification first and call configLocalNotification() before calling other methods
    EG: LocalNotification noti = new LocalNotification();
        noti.configLocalNotification();
  - For setScheduledNotification:
    - Format for date: yyyymmdd EG: 20200731 (31/07/2020)
    - Format for time: hhmmss EG:210427 (21:04:27)
    - days refer to how many days before deadline to send the notification
    - Default: send at 12pm, 1 day before deadline
 */

class LocalNotification {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher'); //'app_icon
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendInstantNotification({String title, String body}) async {
    // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //     'your channel id', 'your channel name', 'your channel description',
    //     importance: Importance.Max, priority: Priority.High, ticker: 'Workly');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Workly', 'Workly', 'Handy project management buddy',
        importance: Importance.Max, priority: Priority.High, ticker: 'Workly');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }  
  
  Future<void> setScheduledNotification({String title, String body, String date, int days, String time}) async {
    String _time = time == null ? "120000" : time;
    int _days = days == null ? 1 : days;
    var scheduledNotificationDateTime = DateTime.parse(date + "T" + _time).subtract(Duration(days: _days));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Workly', 'Workly', 'Handy project management buddy',
        importance: Importance.Max, priority: Priority.High, ticker: 'Workly');
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        title,
        body,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
}