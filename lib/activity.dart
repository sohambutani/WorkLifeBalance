import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(GoalActivityApp());
}

class GoalActivityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal & Activity Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ActivityPage(),
    );
  }
}

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final CollectionReference _activityCollection =
  FirebaseFirestore.instance.collection('activities');

  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _fetchActivitiesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
        elevation: 8,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showActivityDetails(context, activities[index]);
                  },
                  child: _buildActivityContainer(activities[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoalActivityApp()),
                );
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
                _openCalendar(context);
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
          _showAddActivityPopup(context);
        },
        backgroundColor: Colors.transparent,
        elevation: 8,
        shape: CircleBorder(),
        child: Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
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
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityContainer(Activity activity) {
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
        activity.name,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  void _showAddActivityPopup(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Details of your activity',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Activity Name'),
                    controller: nameController,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Activity Description'),
                    controller: descriptionController,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Start Date'),
                          onTap: () async {
                            final DateTime? pickedDate = await _selectDate(context, DateTime.now());
                            if (pickedDate != null) {
                              setState(() {
                                startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          controller: startDateController,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Start Time'),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await _selectTime(context, TimeOfDay.now());
                            if (pickedTime != null) {
                              setState(() {
                                startTimeController.text = pickedTime.format(context);
                              });
                            }
                          },
                          controller: startTimeController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'End Date'),
                          onTap: () async {
                            final DateTime? pickedDate = await _selectDate(context, DateTime.now());
                            if (pickedDate != null) {
                              setState(() {
                                endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          controller: endDateController,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'End Time'),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await _selectTime(context, TimeOfDay.now());
                            if (pickedTime != null) {
                              setState(() {
                                endTimeController.text = pickedTime.format(context);
                              });
                            }
                          },
                          controller: endTimeController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _addActivityToFirestore(
                        nameController.text,
                        descriptionController.text,
                        startDateController.text,
                        endDateController.text,
                        startTimeController.text,
                        endTimeController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addActivityToFirestore(String name, String description, String startDateStr, String endDateStr, String startTimeStr, String endTimeStr) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('user_email');

      if (userEmail != null) {
        DateTime startDate = DateTime.parse(startDateStr);
        DateTime endDate = DateTime.parse(endDateStr);
        TimeOfDay startTime = _parseTimeOfDay(startTimeStr);
        TimeOfDay endTime = _parseTimeOfDay(endTimeStr);

        await _activityCollection.add({
          'email': userEmail,
          'name': name,
          'description': description,
          'startDate': startDate,
          'endDate': endDate,
          'startTime': startTime,
          'endTime': endTime,
        });

        setState(() {
          activities.add(Activity(
            name: name,
            description: description,
            startTime: startDate.add(Duration(hours: startTime.hour, minutes: startTime.minute)),
            endTime: endDate.add(Duration(hours: endTime.hour, minutes: endTime.minute)),
          ));
        });
      } else {
        print('User email not found in SharedPreferences');
      }
    } catch (e) {
      print('Error adding activity to Firestore: $e');
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    List<String> parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _showActivityDetails(BuildContext context, Activity activity) async {
    TextEditingController nameController =
    TextEditingController(text: activity.name);
    TextEditingController descriptionController =
    TextEditingController(text: activity.description);
    TextEditingController startDateController =
    TextEditingController(text: _formatDate(activity.startTime));
    TextEditingController endDateController =
    TextEditingController(text: _formatDate(activity.endTime));
    TextEditingController startTimeController = TextEditingController(
        text: activity.startTime.hour.toString() +
            ":" +
            activity.startTime.minute.toString());
    TextEditingController endTimeController = TextEditingController(
        text: activity.endTime.hour.toString() +
            ":" +
            activity.endTime.minute.toString());

    DateTime? newStartDate;
    DateTime? newEndDate;
    TimeOfDay? newStartTime;
    TimeOfDay? newEndTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Activity'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Activity Name'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                  InputDecoration(labelText: 'Activity Description'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startDateController,
                        decoration: InputDecoration(labelText: 'Start Date'),
                        onTap: () async {
                          newStartDate = await _selectDate(
                              context, activity.startTime);
                          if (newStartDate != null) {
                            setState(() {
                              activity.startTime = newStartDate!;
                              startDateController.text =
                                  _formatDate(newStartDate!);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: startTimeController,
                        decoration:
                        InputDecoration(labelText: 'Start Time'),
                        onTap: () async {
                          newStartTime = await _selectTime(
                              context, TimeOfDay.fromDateTime(activity.startTime));
                          if (newStartTime != null) {
                            setState(() {
                              activity.startTime = DateTime(
                                activity.startTime.year,
                                activity.startTime.month,
                                activity.startTime.day,
                                newStartTime!.hour,
                                newStartTime!.minute,
                              );
                              startTimeController.text = newStartTime!.format(context);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: endDateController,
                        decoration: InputDecoration(labelText: 'End Date'),
                        onTap: () async {
                          newEndDate = await _selectDate(
                              context, activity.endTime);
                          if (newEndDate != null) {
                            setState(() {
                              activity.endTime = newEndDate!;
                              endDateController.text =
                                  _formatDate(newEndDate!);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: endTimeController,
                        decoration: InputDecoration(labelText: 'End Time'),
                        onTap: () async {
                          newEndTime = await _selectTime(
                              context, TimeOfDay.fromDateTime(activity.endTime));
                          if (newEndTime != null) {
                            setState(() {
                              activity.endTime = DateTime(
                                activity.endTime.year,
                                activity.endTime.month,
                                activity.endTime.day,
                                newEndTime!.hour,
                                newEndTime!.minute,
                              );
                              endTimeController.text = newEndTime!.format(context);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Activity updatedActivity = Activity(
                  name: nameController.text,
                  description: descriptionController.text,
                  startTime: activity.startTime,
                  endTime: activity.endTime,
                );
                setState(() {
                  activity.name = updatedActivity.name;
                  activity.description = updatedActivity.description;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchActivitiesFromFirestore() async {
    try {
      QuerySnapshot snapshot = await _activityCollection.get();
      List<Activity> fetchedActivities = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Activity.fromMap(data);
      }).toList();
      setState(() {
        activities = fetchedActivities;
      });
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  void _openCalendar(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // Handle the selected date
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

  Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    return pickedTime;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Activity {
  String name;
  String description;
  DateTime startTime;
  DateTime endTime;

  Activity({
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      name: map['name'],
      description: map['description'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
    );
  }
}
