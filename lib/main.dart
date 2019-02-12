import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:repeat_me/views/add_task.dart';
import 'package:repeat_me/util/notification_manager.dart';
import 'package:repeat_me/util/organize_list.dart';
import 'package:repeat_me/data/reminder.dart';
import 'package:repeat_me/widgets/task_full.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String reminderKey = 'userReminders';
List<Reminder> reminders = [];
List<Reminder> remindersCopy = [];
Color appBarColor = Colors.blue;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
          primarySwatch: Colors.blue,
          textSelectionColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.grey[800],
          )),
      title: 'Repeat Me',
      home: new MyHomePage(title: 'Repeat Me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget taskList;

  Future<String> getReminders() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getString(reminderKey) != null) {
      return sp.getString(reminderKey);
    } else {
      return null;
    }
  }

  void writeChangesToFile() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(reminderKey, json.encode(reminders));
  }

  void deepCopyReminders() {
    remindersCopy = [];
    for (int i = 0; i < reminders.length; i++) {
      remindersCopy.add(reminders[i]);
    }
  }

  void deepCopyBackToReminders() {
    reminders = [];
    for (int i = 0; i < remindersCopy.length; i++) {
      reminders.add(remindersCopy[i]);
    }
  }

  Widget getTaskList() {
    if (reminders.length == 0) {
      return Text('Add a Reminder Below!');
    } else {
      setState(() {
        appBarColor = reminders[0].cardColor;
      });
      return ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final currentTask = reminders[index];
          print(currentTask.notificationID);
          return Dismissible(
            key: Key(currentTask.notificationID.toString()),
            onDismissed: (direction) {
              deepCopyReminders();
              reminders.remove(currentTask);
              cancelSpecificReminder(currentTask);
              writeChangesToFile();
              Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Removed ' + ' "${currentTask.cardTitle}" '),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      deepCopyBackToReminders();
                      setState(() {
                        taskList = getTaskList();
                      });
                      rescheduleNotification(currentTask);
                      writeChangesToFile();
                    },
                  )));
              setState(() {
                if (reminders.length == 0) {
                  appBarColor = Colors.blue;
                } else {
                  appBarColor = reminders[0].cardColor;
                }
              });
            },
            background: Container(color: Colors.transparent),
            child: Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Task(currentTask,currentTask.cardTitle, currentTask.cardSubText, currentTask.cardColor, currentTask.cardAccent),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    reminders = []; //Wipe reminders so we don't have to worry about doubling up on existing reminders
    getReminders().then((String userData) {
      json.decode(userData).forEach((map) => reminders.add(new Reminder.fromJson(map)));
      setState(() {
        taskList = getTaskList();
      });
    }).catchError((e) {
      print('failed to get data');
    });
    setState(() {
      taskList = getTaskList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      taskList = getTaskList();
    });
    return new WillPopScope(
      child: new Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 3.0,
          title: Text(
            'Reminders',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            new PopupMenuButton<String>(
              onSelected: (String organizeType){
                setState(() {
                  if(organizeType == 'alpha'){
                    reminders = organizeByAlphabet(reminders);      
                  }else if(organizeType ==  'color'){
                    reminders = organizeByColor(reminders);
                  }else if(organizeType == 'date'){
                    reminders = organizeByCreationDate(reminders);
                  }
                  writeChangesToFile();
                  taskList = getTaskList();
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: null,
                  child: const Text('Sort by:'),
                ),
                const PopupMenuItem<String>(
                  value: 'alpha',
                  child: const Text('Alphabetical'),
                ),
                const PopupMenuItem<String>(
                  value: 'color',
                  child: const Text('Color'),
                ),
                const PopupMenuItem<String>(
                  value: 'date',
                  child: const Text('Creation Date'),
                ),
              ],
            ),
          ],
          centerTitle: false,
          automaticallyImplyLeading: false, //Removes the back button from appearing
        ),
        body: new Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: taskList,
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask(), maintainState: false));
          },
          tooltip: 'Add Reminder',
          elevation: 6.0,
          child: new Icon(Icons.add, color: Colors.black),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
      onWillPop: () async => false, //User can't hit back button on this screen
    );
  }
}
