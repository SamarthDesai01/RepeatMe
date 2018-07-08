import 'package:flutter/material.dart';

//Use the reminder class to hold all relevant data for each reminder,
//Used for persistence
class Reminder {
  String _cardTitle;
  String _cardSubText;

  Color _cardColor;
  Color _cardAccent;

  int _reminderType; //Integer identifying the type of reminder, 0 - Weekday, 1 - Number, 2 - Date, see notification_manager.dart for more details

  List<bool> _enabledDays; //Boolean array from weekday picker that lists which buttons are enabled
  int _repeatEvery; //Number from text entry for repeating every certain number of days
  DateTime _repeatStartDate; //Date to start repeating reminders
  DateTime _specificDate; //Specific DateTime object
  DateTime _reminderTime; //Scheduled time to show reminders, still need to implement

  int _notificationID; //Unique id to use for this Reminder object, usually passed in as a UNIX timestamp

  Reminder(this._cardTitle, this._cardSubText, this._cardColor, this._cardAccent, this._reminderType, this._enabledDays, this._repeatEvery, this._repeatStartDate,
      this._specificDate, this._reminderTime, this._notificationID);

  Reminder.fromJson(Map<String, dynamic> r) {
    _cardTitle = r['cardTitle'];
    _cardSubText = r['cardSubText'];
    _cardColor = Color(r['cardColor']);
    _cardAccent = Color(r['cardAccent']);
    _reminderType = r['reminderType'];
    _enabledDays = r['enabledDays'].cast<bool>();
    _repeatEvery = r['repeatEvery'];
    _repeatStartDate = DateTime.parse(r['repeatStartDate']);
    _specificDate = DateTime.parse(r['specificDate']);
    _reminderTime = DateTime.parse(r['reminderTime']);
    _notificationID = r['notificationID'];
  }

  Map<String, dynamic> toJson() => {
        'cardTitle': _cardTitle,
        'cardSubText': _cardSubText,
        'cardColor': _cardColor.value,
        'cardAccent': _cardAccent.value,
        'reminderType': _reminderType,
        'enabledDays': _enabledDays,
        'repeatEvery': _repeatEvery,
        'repeatStartDate': _repeatStartDate.toString(),
        'specificDate': _specificDate.toString(),
        'reminderTime': _reminderTime.toString(),
        'notificationID': _notificationID,
      };

  int get notificationID => _notificationID;

  DateTime get reminderTime => _reminderTime;

  DateTime get specificDate => _specificDate;

  DateTime get repeatStartDate => _repeatStartDate;

  int get repeatEvery => _repeatEvery;

  List<bool> get enabledDays => _enabledDays;

  int get reminderType => _reminderType;

  Color get cardAccent => _cardAccent;

  Color get cardColor => _cardColor;

  String get cardSubText => _cardSubText;

  String get cardTitle => _cardTitle;
}
