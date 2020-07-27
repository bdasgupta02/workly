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

  Future<void> sendInstantNotification({int id, String title, String body}) async {
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
        id, title, body, platformChannelSpecifics);
  }  
  
  Future<void> setScheduledNotification({int id, String title, String body, DateTime dateTime}) async {
    var scheduledNotificationDateTime = dateTime;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Workly', 'Workly', 'Handy project management buddy',
        importance: Importance.Max, priority: Priority.High, ticker: 'Workly');
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        id,
        title,
        body,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelNoti(int id) async {
    id == null ? await flutterLocalNotificationsPlugin.cancelAll() : await flutterLocalNotificationsPlugin.cancel(id);
  }
}