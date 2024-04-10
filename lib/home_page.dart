import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late tz.Location selectedLocation;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    selectedLocation = tz.local;
  }

  Future<void> _initializeNotifications() async {
    // Initialize notifications plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone
    tz.initializeTimeZones();
  }

  Future<void> _scheduleReminder(TimeOfDay time) async {
    // Configure the notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Get selected time and convert it to TZDateTime
    final now = tz.TZDateTime.now(selectedLocation);
    final selectedDateTime = tz.TZDateTime(
        selectedLocation, now.year, now.month, now.day, time.hour, time.minute);

    // Ensure that the scheduled time is in the future
    if (selectedDateTime.isBefore(now)) {
      // Increment the day if the selected time is before the current time
      selectedDateTime.add(const Duration(days: 1));
    }

    // Schedule reminder at selected time
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder Title',
      'Reminder Body',
      selectedDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'Custom_Sound',
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        // Convert the selected time to the local time zone
        selectedLocation = tz.local;
      });
      // Schedule reminder with selected time
      await _scheduleReminder(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _selectTime(context),
          child: const Text('Select Time and Schedule Reminder'),
        ),
      ),
    );
  }
}
