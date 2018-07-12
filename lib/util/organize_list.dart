import 'package:flutter/material.dart';
import 'package:repeat_me/data/reminder.dart';


List<Reminder> organizeByCreationDate(List<Reminder> currentList){
    List<Reminder> sortedReminders = [];
    List<List<int>> sortReminders = [];
  if(currentList.length == 0){
    return sortedReminders = [];
  }
  //Group together all the current notifications by ID and their position in the list
  for(int i = 0; i < currentList.length; i++){
    Reminder currentReminder = currentList[i];
    sortReminders.add([currentReminder.notificationID, i]);
  }

  //Sort the list by ascending notificationID order
  sortReminders.sort((a,b) => a[0].compareTo(b[0])); 
  
  for(int i = 0; i < sortReminders.length; i++){
    //Recreate the list using the index stored in the sorted array of arrays to pull from 
    //the original list and add them as an ordered list of notifications
    sortedReminders.add(currentList[sortReminders[i][1]]); 
  }
  return sortedReminders;
}

List<Reminder> organizeByColor(List<Reminder> currentList){
  List<Reminder> sortedReminders = [];
  int currentIndex = 0;
  bool addedReminder = false; 

  if(currentList.length == 0){ //If we receive an empty array return the same thing
    return sortedReminders;
  }
  
  for(int i = 0; i < currentList.length; i++){
    Reminder currentReminder = currentList[i];
    //Make sure to have a value in our sorted reminders list to start comparisons with
    if(sortedReminders.length == 0){ 
      sortedReminders.add(currentReminder);
      addedReminder = true;
    }
    //Loop through our sorted array looking for color matches, 
    //if one is found insert the current reminder right after the matched element
    while(currentIndex < sortedReminders.length && !addedReminder){ 
      Reminder reminderInSorted = sortedReminders[currentIndex];
      if(reminderInSorted.cardColor == currentReminder.cardColor){
        sortedReminders.insert(currentIndex+1, currentReminder);
        addedReminder = true;
      }else if(currentIndex == sortedReminders.length - 1){ //Looped through all the elements but still wasn't able to find a match. Just add to the end of the array as a result
        sortedReminders.add(currentReminder);
        addedReminder = true;
      }
      currentIndex++; //Increment our index in sortedReminders 
    }
    currentIndex = 0; //Reset while conditions for next for loop iteration
    addedReminder = false; 
  }
  return sortedReminders;
}

List<Reminder> organizeByAlphabet(List<Reminder> currentList){
    List<Reminder> sortedReminders = [];
    List<List<dynamic>> sortReminders = [];
  if(currentList.length == 0){
    return sortedReminders = [];
  }
  //Group together all the current notifications by title and their position in the list
  for(int i = 0; i < currentList.length; i++){
    Reminder currentReminder = currentList[i];
    sortReminders.add([currentReminder.cardTitle, i]);
  }

  //Sort the list by ascending alphabetic order
  sortReminders.sort((a,b) => a[0].compareTo(b[0])); 
  
  for(int i = 0; i < sortReminders.length; i++){
    //Recreate the list using the index stored in the sorted array of arrays to pull from 
    //the original list and add them as an ordered list of notifications
    sortedReminders.add(currentList[sortReminders[i][1]]); 
  }
  return sortedReminders;
}

