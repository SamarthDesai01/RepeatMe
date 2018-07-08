import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:repeat_me/views/add_task.dart';
import 'package:repeat_me/util/notification_manager.dart';
import 'package:repeat_me/data/reminder.dart';
import 'package:repeat_me/widgets/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String reminderKey = 'userReminders';
List<Reminder> reminders = [];

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
      title: 'Repeat Me!',
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

  Widget getTaskList() {
    if (reminders.length == 0) {
      return Text('Add a Reminder Below!');
    } else {
      return ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final currentTask = reminders[index];
          return Dismissible(
            key: Key(currentTask.notificationID.toString()),
            onDismissed: (direction) {
              reminders.removeAt(index);
              cancelSpecificReminder(currentTask);
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Removed ' + ' "${currentTask.cardTitle}" ')));
              writeChangesToFile();
              print(reminders);
            },
            background: Container(color: Colors.transparent),
            child: Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: TaskCard(currentTask.cardTitle, currentTask.cardSubText, currentTask.cardColor, currentTask.cardAccent),
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
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          'Repeat Me!',
          style: TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask()));
        },
        tooltip: 'Add Reminder',
        elevation: 6.0,
        child: new Icon(Icons.add, color: Colors.black),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
