import 'package:flutter/material.dart';
import 'package:repeat_me/data/reminder.dart';


List<Reminder> organizeByCreationDate(List<Reminder> currentList){
    List<Reminder> sortedReminders = [];
    List<List<int>> sortReminders = [];
  if(currentList.length == 0){
    return sortedReminders = [];
  }
  for(int i = 0; i < currentList.length; i++){
    Reminder currentReminder = currentList[i];
    sortReminders.add([currentReminder.notificationID, i]);
  }
  sortReminders.sort((a,b) => a[0].compareTo(b[0]));
  for(int i = 0; i < sortReminders.length; i++){
    sortedReminders.add(currentList[sortReminders[i][1]]);
  }
  return sortedReminders;
}