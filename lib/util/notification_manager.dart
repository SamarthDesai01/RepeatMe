import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:repeat_me/data/reminder.dart';

//File to generate all relevant notification data

final int repeatNotifCount = 50; //Number of times to schedule a recurring notification for number based reminders
final String warningText = 'This is the last instance of this notification, recreate it if you would like it to continue';

final int weekdayID = 0; //Identifier for reminders that are weekday based - 'Weekday Choice Chip'
final int numberID = 1; //Identifier for reminders that are number based - 'Number Choice Chip'
final int dateID = 2; // Identifier for reminders that are specific day based - 'Date Choice Chip'

var initializationSettingsAndroid = new AndroidInitializationSettings('ic_launcher');
var initializationSettingsIOS = new IOSInitializationSettings();
var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

var androidPlatformChannelSpecifics = new AndroidNotificationDetails('channelRemind', 'Reminders', 'Reminders', importance: Importance.High, priority: Priority.High);
var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

void generateNotification(Reminder reminder) async {
  String notificationTitle = reminder.cardTitle;
  String notificationBody = reminder.cardSubText;
  int reminderType = reminder.reminderType;
  int notificationID = reminder.notificationID;
  List<bool> enabledDays = reminder.enabledDays;
  int repeatEvery = reminder.repeatEvery;
  DateTime repeatStartDate = reminder.repeatStartDate;
  DateTime specificDate = reminder.specificDate;
  DateTime reminderTime = reminder.reminderTime;

  Time defaultTime = Time(reminderTime.hour, reminderTime.minute, 0);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (reminderType == weekdayID) {
    //Code for weekday based reminders
    if (enabledDays[0])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Sunday, defaultTime, platformChannelSpecifics);
    if (enabledDays[1])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Monday, defaultTime, platformChannelSpecifics);
    if (enabledDays[2])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Tuesday, defaultTime, platformChannelSpecifics);
    if (enabledDays[3])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Wednesday, defaultTime, platformChannelSpecifics);
    if (enabledDays[4])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Thursday, defaultTime, platformChannelSpecifics);
    if (enabledDays[5])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Friday, defaultTime, platformChannelSpecifics);
    if (enabledDays[6])
      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(notificationID, notificationTitle, notificationBody, Day.Saturday, defaultTime, platformChannelSpecifics);
  } //Weekday reminder

  if (reminderType == numberID) {
    //Code for number based reminders
    if (repeatEvery != 0 && repeatEvery > 0) {
      //Double check no one pasted in outside text, only allow positive numbers larger than 0
      await flutterLocalNotificationsPlugin.schedule(
          //Schedule the first notification on the specified start date
          notificationID,
          notificationTitle,
          notificationBody,
          repeatStartDate,
          platformChannelSpecifics);

      repeatStartDate = reminderTime; //Reminder time contains both repeat start date and specified start time,

      for (int i = 0; i < repeatNotifCount; i++) {
        notificationID++; //Keep this here, or else notifIDs will collide and cause the last warning notif to not display.
        repeatStartDate = repeatStartDate.add(Duration(days: repeatEvery));
        print(repeatStartDate.toString());
        if (i != repeatNotifCount - 1) {
          await flutterLocalNotificationsPlugin.schedule(notificationID, notificationTitle, notificationBody, repeatStartDate, platformChannelSpecifics);
        } else {
          //Last scheduling of this number based reminder, let the user know to recreate it
          await flutterLocalNotificationsPlugin.schedule(notificationID, notificationTitle, warningText, repeatStartDate, platformChannelSpecifics);
        }
      }
    }
  }
  if (reminderType == dateID) {
    //Code for specific date based reminders
    print(reminderTime.toString());
    await flutterLocalNotificationsPlugin.schedule(notificationID, notificationTitle, notificationBody, reminderTime, platformChannelSpecifics);
  }
}

void cancelAllReminders() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  flutterLocalNotificationsPlugin.cancelAll();
}

void cancelSpecificReminder(Reminder remind) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  int notificationID = remind.notificationID;

  if (remind.reminderType == weekdayID || remind.reminderType == dateID)
    flutterLocalNotificationsPlugin.cancel(notificationID);
  else if (remind.reminderType == numberID) {
    for (int i = 0; i < repeatNotifCount + 1; i++) {
      flutterLocalNotificationsPlugin.cancel(notificationID);
      notificationID++;
    }
  }
}

//Reschedule notifications that were undo-ed but only schedule the notifs that weren't fired yet. Keep notif ids in sync with removed task
// so that swiping behavior still correctly cancels the appropriate notifs.
void rescheduleNotification(Reminder remind) {
  int remindType = remind.reminderType;
  DateTime repeatStartDate = remind.repeatStartDate;
  int repeatEvery = remind.repeatEvery;
  int notificationID = remind.notificationID;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (remindType == weekdayID) {
    generateNotification(remind); //Reschedule weekday reminders by default, won't cause repeat notif bug
  } else if (remindType == numberID) {
    for (int i = 0; i < repeatNotifCount + 1; i++) {
      //Account for the original starting reminder so loop once more
      //Only reschedule the remaining reminders for that cancelled notification
      if (repeatStartDate.isAfter(DateTime.now()) && i != repeatNotifCount - 1) {
        //Try to find the next start date
        flutterLocalNotificationsPlugin.schedule(notificationID, remind.cardTitle, remind.cardSubText, repeatStartDate, platformChannelSpecifics);
        print(repeatStartDate);
      } else if (repeatStartDate.isAfter(DateTime.now()) && i == repeatNotifCount - 1) {
        flutterLocalNotificationsPlugin.schedule(notificationID, remind.cardTitle, warningText, repeatStartDate, platformChannelSpecifics);
      }
      notificationID++;
      repeatStartDate = repeatStartDate.add(Duration(days: repeatEvery)); //Increment after so that even the first initial reminder is included
    }
  } else if (remindType == dateID) {
    if (repeatStartDate.isAfter(DateTime.now())) {
      //Only reschedule this alarm if it hasn't fired yet
      generateNotification(remind);
    }
  }
}
