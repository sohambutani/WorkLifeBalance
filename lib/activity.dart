import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Tracker',
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
  List<Activity> activities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Activity Page'),
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  _showAddActivityPopup(context);
                },
                child: Image.asset(
                  'assets/square.png',
                  height: 40,
                  width: 40,
                ),
              ),
            ),
          ),
        ],
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

  void _showAddActivityPopup(BuildContext context) {
    String activityName = '';
    String activityDescription = '';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now();

    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    showModalBottomSheet(
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
                    onChanged: (value) {
                      activityName = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Activity Description'),
                    onChanged: (value) {
                      activityDescription = value;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startDateController,
                          decoration: InputDecoration(labelText: 'Start Date'),
                          onTap: () async {
                            final DateTime? pickedDate = await _selectDate(context, startDate);
                            if (pickedDate != null) {
                              setState(() {
                                startDate = pickedDate;
                                startDateController.text = _formatDate(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: startTimeController,
                          decoration: InputDecoration(labelText: 'Start Time'),
                          onTap: () async {
                            final TimeOfDay? pickedTime =
                            await _selectTime(context, startTime);
                            if (pickedTime != null) {
                              setState(() {
                                startTime = pickedTime;
                                startTimeController.text = pickedTime.format(context);
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
                            final DateTime? pickedDate = await _selectDate(context, endDate);
                            if (pickedDate != null) {
                              setState(() {
                                endDate = pickedDate;
                                endDateController.text = _formatDate(pickedDate);
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
                            final TimeOfDay? pickedTime =
                            await _selectTime(context, endTime);
                            if (pickedTime != null) {
                              setState(() {
                                endTime = pickedTime;
                                endTimeController.text = pickedTime.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      DateTime startDateTime = DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                      );
                      DateTime endDateTime = DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        endTime.hour,
                        endTime.minute,
                      );
                      Activity newActivity = Activity(
                        name: activityName,
                        description: activityDescription,
                        startTime: startDateTime,
                        endTime: endDateTime,
                      );
                      setState(() {
                        activities.add(newActivity);
                      });
                      print('Activity Name: $activityName');
                      print('Activity Description: $activityDescription');
                      print('Start Date: $startDateTime');
                      print('End Date: $endDateTime');
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

  void _showTimePicker(BuildContext context, TextEditingController controller, Function(TimeOfDay pickedTime) onTimePicked) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
      onTimePicked(pickedTime);
    }
  }

  void _showActivityDetails(BuildContext context, Activity activity) async {
    TextEditingController nameController = TextEditingController(text: activity.name);
    TextEditingController descriptionController = TextEditingController(text: activity.description);
    TextEditingController startDateController = TextEditingController(text: _formatDate(activity.startTime));
    TextEditingController endDateController = TextEditingController(text: _formatDate(activity.endTime));
    TextEditingController startTimeController = TextEditingController(text: activity.startTime.hour.toString() + ":" + activity.startTime.minute.toString());
    TextEditingController endTimeController = TextEditingController(text: activity.endTime.hour.toString() + ":" + activity.endTime.minute.toString());

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
                  decoration: InputDecoration(labelText: 'Activity Description'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startDateController,
                        decoration: InputDecoration(labelText: 'Start Date'),
                        onTap: () async {
                          newStartDate = await _selectDate(context, activity.startTime);
                          if (newStartDate != null) {
                            setState(() {
                              activity.startTime = newStartDate!;
                              startDateController.text = _formatDate(newStartDate!);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: startTimeController,
                        decoration: InputDecoration(labelText: 'Start Time'),
                        onTap: () async {
                          newStartTime = await _selectTime(context, TimeOfDay.fromDateTime(activity.startTime));
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
                          newEndDate = await _selectDate(context, activity.endTime);
                          if (newEndDate != null) {
                            setState(() {
                              activity.endTime = newEndDate!;
                              endDateController.text = _formatDate(newEndDate!);
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
                          newEndTime = await _selectTime(context, TimeOfDay.fromDateTime(activity.endTime));
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
}
