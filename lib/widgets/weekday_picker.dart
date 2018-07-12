import 'package:flutter/material.dart';

Color _sundayColor = Colors.grey;
bool _sundayEnable = false;

Color _mondayColor = Colors.grey;
bool _mondayEnable = false;

Color _tuesdayColor = Colors.grey;
bool _tuesdayEnable = false;

Color _wednesdayColor = Colors.grey;
bool _wednesdayEnable = false;

Color _thursdayColor = Colors.grey;
bool _thursdayEnable = false;

Color _fridayColor = Colors.grey;
bool _fridayEnable = false;

Color _saturdayColor = Colors.grey;
bool _saturdayEnable = false;

Color _iconColor = Colors.grey[400];
Color _iconGrey = Colors.grey[400];

List<bool> getEnabledDays() {
  return [_sundayEnable, _mondayEnable, _tuesdayEnable, _wednesdayEnable, _thursdayEnable, _fridayEnable, _saturdayEnable];
}

class WeekdayPicker extends StatefulWidget {
  WeekdayPicker();
  //Return an array of which days are enabled
  List<bool> getEnabledDays() {
    return [_sundayEnable, _mondayEnable, _tuesdayEnable, _wednesdayEnable, _thursdayEnable, _fridayEnable, _saturdayEnable];
  }

  int getNumberOfEnabledDays(){
    int numEnabled = 0;
    List<bool> enabledDays = getEnabledDays();
    for(int i = 0; i < enabledDays.length; i++){
      if(enabledDays[i] == true)
        numEnabled++;
    }
    return numEnabled;
  }

  //Return a string to let the user know which days the reminder will repeat, 
  String getWeekdayString() {
    List<bool> enabledDays = this.getEnabledDays();
    List<String> weekdays = new List();
    int numEnabled = getNumberOfEnabledDays();
    if(numEnabled > 3 && numEnabled < 7){ //To prevent overflow on smaller devices, make the weekday text an acronym
      if (enabledDays[0]) weekdays.add('S');
      if (enabledDays[1]) weekdays.add('M');
      if (enabledDays[2]) weekdays.add('T');
      if (enabledDays[3]) weekdays.add('W');
      if (enabledDays[4]) weekdays.add('Th');
      if (enabledDays[5]) weekdays.add('F');
      if (enabledDays[6]) weekdays.add('S');
      return weekdays.join(" | "); //Exp output S | M | T
    } else{
      if (enabledDays[0]) weekdays.add('Sundays');
      if (enabledDays[1]) weekdays.add('Mondays');
      if (enabledDays[2]) weekdays.add('Tuesdays');
      if (enabledDays[3]) weekdays.add('Wednesdays');
      if (enabledDays[4]) weekdays.add('Thursdays');
      if (enabledDays[5]) weekdays.add('Fridays');
      if (enabledDays[6]) weekdays.add('Saturdays');
      if (enabledDays.every((e) => e == true)) return 'Every day'; //If all days are enabled return a cleaner string
      return weekdays.join(", ");
    }
    print(weekdays.join(','));

  }

  //Redraw the picker with the new colors
  //Call this method when we use the color picker to change theme color, since
  //changes aren't always reflected with the weekday_picker
  void reDraw(Color newColor) {
    if (_sundayEnable) {
      _sundayColor = newColor;
    }
    if (_mondayEnable) {
      _mondayColor = newColor;
    }
    if (_tuesdayEnable) {
      _tuesdayColor = newColor;
    }
    if (_wednesdayEnable) {
      _wednesdayColor = newColor;
    }
    if (_thursdayEnable) {
      _thursdayColor = newColor;
    }
    if (_fridayEnable) {
      _fridayColor = newColor;
    }

    if (_saturdayEnable) {
      _saturdayColor = newColor;
    }
    _iconColor = newColor;
  }

  //Reset all variables to their initial disabled, starting values
  void resetState() {
    _sundayColor = Colors.grey;
    _sundayEnable = false;

    _mondayColor = Colors.grey;
    _mondayEnable = false;

    _tuesdayColor = Colors.grey;
    _tuesdayEnable = false;

    _wednesdayColor = Colors.grey;
    _wednesdayEnable = false;

    _thursdayColor = Colors.grey;
    _thursdayEnable = false;

    _fridayColor = Colors.grey;
    _fridayEnable = false;

    _saturdayColor = Colors.grey;
    _saturdayEnable = false;

    _iconColor = Colors.grey[400];
    _iconGrey = Colors.grey[400];
  }

  @override
  _WeekdayPickerState createState() => new _WeekdayPickerState();
}

class _WeekdayPickerState extends State<WeekdayPicker> {
  List<bool> getEnabledDays() {
    return [_sundayEnable, _mondayEnable, _tuesdayEnable, _wednesdayEnable, _thursdayEnable, _fridayEnable, _saturdayEnable];
  }

  //Returns boolean letting us know if no weekdays are selected
  //True, no buttons selected, let button be gray
  bool iconShouldBeGray() {
    List<bool> enabledDays = getEnabledDays();
    bool foundTruth = false;
    for (int i = 0; i < enabledDays.length; i++) {
      if (enabledDays[i] == true) {
        foundTruth = true;
        break;
      }
    }
    if (!foundTruth) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (iconShouldBeGray()) {
      _iconColor = _iconGrey;
    }
    return Row(
      children: <Widget>[
        Icon(
          Icons.timelapse,
          color: _iconColor,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: _sundayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_sundayEnable == false) {
                        _sundayColor = Theme.of(context).primaryColor;
                        _sundayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else if (_sundayEnable == true) {
                        _sundayColor = Colors.grey;
                        _sundayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                      print(getEnabledDays());
                    });
                  },
                  child: Text(
                    'S',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: _mondayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_mondayEnable == false) {
                        _mondayColor = Theme.of(context).primaryColor;
                        _mondayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else {
                        _mondayColor = Colors.grey;
                        _mondayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                    });
                  },
                  child: Text(
                    'M',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: _tuesdayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_tuesdayEnable == false) {
                        _tuesdayColor = Theme.of(context).primaryColor;
                        _tuesdayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else {
                        _tuesdayColor = Colors.grey;
                        _tuesdayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                    });
                  },
                  child: Text(
                    'T',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: _wednesdayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_wednesdayEnable == false) {
                        _wednesdayColor = Theme.of(context).primaryColor;
                        _wednesdayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else {
                        _wednesdayColor = Colors.grey;
                        _wednesdayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                    });
                  },
                  child: Text(
                    'W',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: _thursdayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_thursdayEnable == false) {
                        _thursdayColor = Theme.of(context).primaryColor;
                        _thursdayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else {
                        _thursdayColor = Colors.grey;
                        _thursdayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                    });
                  },
                  child: Text(
                    'Th',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: _fridayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_fridayEnable == false) {
                        _fridayColor = Theme.of(context).primaryColor;
                        _fridayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else {
                        _fridayColor = Colors.grey;
                        _fridayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                    });
                  },
                  child: Text(
                    'F',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: _saturdayColor,
                  shape: CircleBorder(),
                  onPressed: () {
                    setState(() {
                      if (_saturdayEnable == false) {
                        _saturdayColor = Theme.of(context).primaryColor;
                        _saturdayEnable = true;
                        _iconColor = Theme.of(context).primaryColor;
                      } else {
                        _saturdayColor = Colors.grey;
                        _saturdayEnable = false;
                        if (iconShouldBeGray()) {
                          _iconColor = _iconGrey;
                        }
                      }
                    });
                  },
                  child: Text(
                    'S',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
