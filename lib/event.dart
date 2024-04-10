import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventPage(),
    );
  }
}

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Event> events = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone package
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set timezone to Asia/Kolkata

    // After initializing local notifications and timezone, schedule any notifications
    // Here we can safely call _scheduleNotification
    DateTime eventDate = DateTime.now().add(Duration(days: 1)); // Event date set to tomorrow
    _scheduleNotification('Sample Event', eventDate);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
        elevation: 8, // Add elevation for shadow
        backgroundColor: Colors.white, // Set background color to white
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showEventDetails(context, events[index]);
                  },
                  child: _buildEventContainer(events[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8, // Add elevation for shadow
        shape: CircularNotchedRectangle(), // Set shape to CircularNotchedRectangle
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Add functionality for home button
              },
            ),
            IconButton(
              icon: Icon(Icons.insert_chart),
              onPressed: () {
                // Add functionality for graph button
              },
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                _openCalendar(context); // Add functionality for calendar button
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _shadowPopup(context);
        },
        backgroundColor: Colors.transparent, // Set background color to transparent
        elevation: 8, // Add elevation for shadow
        shape: CircleBorder(), // Set shape to CircleBorder
        child: Container(
          width: 45.0, // Adjust the width and height to make it circular
          height: 45.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Set background color to white to create a circular shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventContainer(Event event) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        event.name,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  void _shadowPopup(BuildContext context) {
    String eventName = '';
    String eventDescription = '';
    DateTime startDate = DateTime.now();

    TextEditingController startDateController = TextEditingController();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Details of your goal',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Event Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a event name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            eventName = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Event Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a event description';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            eventDescription = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: startDateController,
                          decoration: InputDecoration(labelText: 'Date'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null) {
                              startDateController.text =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                              startDate = pickedDate;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Event newEvent = Event(
                                name: eventName,
                                description: eventDescription,
                                startDate: startDate,
                              );
                              setState(() {
                                events.add(newEvent);
                              });
                              print('Event Name: $eventName');
                              print('Event Description: $eventDescription');
                              print('Date: $startDate');
                              _scheduleNotification(eventName, startDate);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _scheduleNotification(String eventName, DateTime eventDate) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    // Create Android notification settings
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Create notification details
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Calculate notification date (e.g., one day before the event date)
    final DateTime notificationDate = eventDate.subtract(const Duration(days: 1));

    // Ensure the notification date is in the future
    if (notificationDate.isAfter(DateTime.now())) {
      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Event Reminder',
        'Your event $eventName is tomorrow!',
        tz.TZDateTime.from(notificationDate, tz.local),
        const NotificationDetails(android: androidPlatformChannelSpecifics),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,

      );
      print('Notification for $eventName scheduled successfully!');
    } else {
      print('Notification date must be in the future.');
    }
  }



  void _showEventDetails(BuildContext context, Event event) async {
    TextEditingController nameController = TextEditingController(text: event.name);
    TextEditingController descriptionController =
    TextEditingController(text: event.description);
    TextEditingController startDateController =
    TextEditingController(text: _formatDate(event.startDate));

    DateTime? newStartDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Event Description'),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    newStartDate = await _selectDate(context, event.startDate);
                    if (newStartDate != null) {
                      setState(() {
                        event.startDate = newStartDate!;
                        startDateController.text = _formatDate(newStartDate!);
                      });
                    }
                  },
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: startDateController,
                      decoration: InputDecoration(labelText: 'Date'),
                      readOnly: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Event updatedEvent = Event(
                  name: nameController.text,
                  description: descriptionController.text,
                  startDate: newStartDate ?? event.startDate,
                );
                Navigator.pop(context, updatedEvent);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    setState(() {
      event.name = nameController.text;
      event.description = descriptionController.text;
      // Start and end dates remain unchanged
    });
  }

  void _openCalendar(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // Handle the selected date, such as storing it or performing any required actions
      print('Selected date: $selectedDate');
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Event {
  String name;
  String description;
  DateTime startDate;

  Event({
    required this.name,
    required this.description,
    required this.startDate,
  });
}
