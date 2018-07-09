import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_picker/material_color_picker.dart';
import 'package:repeat_me/data/reminder.dart';
import 'package:repeat_me/main.dart';
import 'package:repeat_me/util/notification_manager.dart';
import 'package:repeat_me/widgets/task.dart';
import 'package:repeat_me/widgets/weekday_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String reminderKey = 'userReminders';
List<Reminder> reminders = [];

class AddTask extends StatefulWidget {
  AddTask();

  @override
  _AddTaskState createState() => new _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String _currentTaskName = 'Card Preview'; //Card title
  String _currentTaskSubText; //Card subtext

  List<bool> _enabledDays; //Store the array of bools for weekday picker's enabled days
  int _repeatEveryNumber; //Number holding the input for the 'Repeat Every' text box, used for number based reminders
  DateTime _whenToRepeat; //Hold the DateTime object for reminders on specific days, only for 'Date' use
  DateTime _repeatStartDate; //When to start number based reminders
  DateTime _reminderTime; //Unused for now, but time to schedule reminders

  Color _previewCardColor;
  Color _previewCardAccent;
  Color _repeatEveryIcon;

  int _choiceChipValue; //The active chip right now, number equal to one of the three values below
  int _weekdayChipIndex = 0; //Identifier for chips letting us know weekday has been selected
  int _numberChipIndex = 1; //Repeat every number of days identifier
  int _specificDayChipIndex = 2; //Remind on a specific day

  WeekdayPicker picker; //Weekday picker

  //Test method to display notifications
  Future _showNotification() async {}

  //Method to create the datepicker dialog
  Future<Null> _selectDate(BuildContext context, int remindType) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null)
      setState(() {
        if (remindType == _numberChipIndex) {
          //Picked a date for number based reminders, only update the start date but not subtext
          _repeatStartDate = picked.toLocal(); //Update _repeatStartDate when date picker is called to schedule a start date
        }
        if (remindType == _specificDayChipIndex) {
          //Picked a date for specific date reminders, update card subtext and specific date reminder
          _whenToRepeat = picked.toLocal(); //Update _whenToRepeat for specific date reminders
          _currentTaskSubText = 'On ' + picked.toString().split(' ')[0]; //Update card to reflect this date
        }
      });
  }

  void getReminders() async {
    reminders = [];
    SharedPreferences sp = await SharedPreferences.getInstance();
    //String userData = sp.getString(reminderKey);
    if (sp.getString(reminderKey) != null) {
      json.decode(sp.getString(reminderKey)).forEach((map) => reminders.add(new Reminder.fromJson(map)));
      print(sp.getString(reminderKey));
    }
  }

  void writeChangesToFile() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(reminderKey, json.encode(reminders));
  }

  //Method for dynamically generating widgets based on which chip is selected
  Widget getPicker(int option) {
    if (option == 0) {
      //Display the weekday picker
      return Listener(
        //Listen for touch events on the day picker
        behavior: HitTestBehavior.translucent,
        onPointerDown: (p) {
          //If tapped redraw
          setState(() {
            //Force a redraw of the current screen
          });
        },
        onPointerUp: (p) {
          setState(() {
            //Force a redraw of the current screen
          });
        },
        child: picker, //Hold the day picker
      );
    } else if (option == 1) {
      //Number entry
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                Icons.history,
                color: _repeatEveryIcon,
              ),
              Padding(
                //Padding used to center the icon vertically
                padding: EdgeInsets.only(top: 15.0),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
            ),
          ),
          Container(
            height: 60.0,
            width: 54.0,
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                RaisedButton(
                  color: _previewCardColor,
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.date_range,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _selectDate(context, _numberChipIndex);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              //Repeat Days entry field
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
              maxLength: 3,
              maxLengthEnforced: true,
              style: TextStyle(fontSize: 10.0, height: .9, color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Repeat Every',
                fillColor: Colors.grey[100],
                filled: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              onChanged: (String s) {
                //Process input and update preview card
                s = s.replaceAll(' ', ''); //Trim all spaces
                s = s.replaceAll(',', ''); //Trim all commas
                s = s.replaceAll('.', ''); //Trim all periods
                s = s.replaceAll('-', ''); //Trim all dashes
                setState(() {
                  if (s == '') {
                    _currentTaskSubText = '';
                  } else if (s == '1') {
                    _currentTaskSubText = "Every day";
                  } else {
                    _currentTaskSubText = "Every " + s + " days";
                  }
                  _repeatEveryIcon = _previewCardColor;
                });
                _repeatEveryNumber = int.parse(s); //Convert our trimmed string to an int to save for our Reminder object
              },
              onSubmitted: (s) {
                setState(() {
                  _repeatEveryIcon = Colors.grey[600];
                });
              },
            ),
          ),
        ],
      );
    } else if (option == 2) {
      return Row(
        children: <Widget>[
          Icon(
            Icons.date_range,
            color: _previewCardColor,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 134.0),
          ),
          RaisedButton(
            color: _previewCardColor,
            child: Text('Pick Date', style: TextStyle(color: Colors.white)),
            onPressed: () {
              _selectDate(context, _specificDayChipIndex);
            },
          ),
        ],
      );
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _currentTaskName = 'Card Preview';
    picker = new WeekdayPicker();
    _currentTaskSubText = '';
    _previewCardColor = Colors.blue; //The default theme color
    _previewCardAccent = Colors.white10; //Set to transparent white so InkWells for all taps look normal
    _choiceChipValue = 0; //Set to 0, so that the weekday chip is enabled by default

    picker.reDraw(_previewCardColor); //Redraw the picker with enabled

    _repeatEveryIcon = Colors.grey;
    _enabledDays = picker.getEnabledDays();
    _repeatStartDate = DateTime.now().toLocal();
    _reminderTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); //Initialize reminder time with reminder time at very start of the day

    getReminders(); //Update our reminders array to add to later on

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_choiceChipValue == 0) {
      //Generate the weekday picker subtext on redraw if weekdays option is selected
      _currentTaskSubText = picker.getWeekdayString();
    } else if (_choiceChipValue == 1) {
      _currentTaskSubText;
    }

    picker.reDraw(_previewCardColor);

    return Theme(
      data: ThemeData(
        primaryColor: _previewCardColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Task'),
          backgroundColor: _previewCardColor,
        ),
        body: new Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: TaskCard(_currentTaskName, _currentTaskSubText, _previewCardColor, _previewCardAccent),
              ),
              Padding(
                padding: EdgeInsets.only(top: 28.0),
                child: TextField(
                  maxLength: 30,
                  maxLengthEnforced: true,
                  autofocus: true,
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.beenhere,
                    ),
                    labelText: 'Task Name',
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  onChanged: (String s) {
                    setState(() {
                      _currentTaskName = s;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Icon(
                    Icons.repeat,
                    color: _previewCardColor,
                  ),
                  new Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70.0),
                    ),
                  ),
                  new ChoiceChip(
                    //Weekday Chip
                    label: Text('Weekday'),
                    selected: _choiceChipValue == _weekdayChipIndex,
                    onSelected: (bool selected) {
                      setState(() {
                        _currentTaskSubText = ''; //Wipe Repeat text on each click
                        _choiceChipValue = selected ? _weekdayChipIndex : null; //Set as current active button, using its unique chip index
                      });
                    },
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0),
                  ),
                  new ChoiceChip(
                    //Number Chip
                    label: Text('Number'),
                    selected: _choiceChipValue == _numberChipIndex,
                    onSelected: (bool selected) {
                      setState(() {
                        _currentTaskSubText = '';
                        _choiceChipValue = selected ? _numberChipIndex : null;
                      });
                    },
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0),
                  ),
                  new ChoiceChip(
                    //Date Chip
                    label: Text('Date'),
                    selected: _choiceChipValue == _specificDayChipIndex,
                    onSelected: (bool selected) {
                      setState(() {
                        _currentTaskSubText = '';
                        _choiceChipValue = selected ? _specificDayChipIndex : null;
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 26.0),
              ),
              Container(
                //Dynamically create the picker widget based on the selected chip
                child: getPicker(_choiceChipValue),
              ),
              Padding(
                padding: EdgeInsets.only(top: 26.0),
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.color_lens,
                    color: _previewCardColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 312.0),
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: _previewCardColor,
                      shape: CircleBorder(),
                      onPressed: () {
                        Color startColor;
                        Future<Color> askedToLead() async => await showDialog(
                              context: context,
                              child: new SimpleDialog(
                                title: const Text('Select color'),
                                children: <Widget>[
                                  new ColorPicker(
                                    type: MaterialType.transparency,
                                    onColor: (color) {
                                      setState(() {
                                        _previewCardColor = color;
                                        picker.reDraw(color); //Update colors to reflect new picked color
                                      });
                                      Navigator.pop(context, color);
                                    },
                                    currentColor: startColor,
                                  ),
                                ],
                              ),
                            );

                        askedToLead(); //Call the color picker dialog
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: RaisedButton(
                  //Submit Button
                  color: _previewCardColor,
                  disabledTextColor: Colors.black26,
                  disabledColor: Colors.grey,
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: !(_currentTaskSubText.length > 1) //If button subtext exists, so does valid input, thus enable the button if true
                      ? null
                      : () async {
                          var uniqueID = DateTime.now().hashCode;
                          if (_whenToRepeat == null) {
                            //Only initialized if specific date chosen, make sure to assign it a value so it doesn't cause JSON parsing issues
                            _whenToRepeat = DateTime.now().toLocal();
                          }
                          var newReminder = Reminder(_currentTaskName, _currentTaskSubText, _previewCardColor, _previewCardAccent, _choiceChipValue, picker.getEnabledDays(),
                              _repeatEveryNumber, _repeatStartDate, _whenToRepeat, _reminderTime, uniqueID);
                          reminders.add(newReminder); //Add new reminder to current list of reminders
                          generateNotification(newReminder); //Set a notification based on this reminder
                          writeChangesToFile(); //Migrate changes to local storage
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage())); //Navigate back to home screen
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
