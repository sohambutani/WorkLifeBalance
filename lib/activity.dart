import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:worklifebalance/activityStatusGraph.dart';

import 'ActivitiesStatusPage.dart'; // Import the uuid package

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityStatusGraph()),
                );
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
            icon:  Icon(
              Icons.verified_rounded,

            ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityStatusPage()),
                );
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
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: activity.status == 'Completed',
                onChanged: (value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm'),
                        content: Text('Are you sure you want to mark this activity as completed?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                if (value!) {
                                  activity.status = 'Completed';
                                } else {
                                  activity.status = ''; // Clear the status
                                }
                              });
                              _updateActivityStatus(activity);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                activeColor: activity.status == 'Completed' ? Colors.green : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showActivityDetails(context, activity);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${activity.description}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start Date: ${_formatDate(activity.startDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'End Date: ${_formatDate(activity.endDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmation(context, activity);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to delete this activity?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteActivity(activity);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteActivity(Activity activity) async {
    try {
      await FirebaseFirestore.instance.collection('activities').doc(activity.id).delete();
      setState(() {
        activities.removeWhere((element) => element.id == activity.id);
      });
    } catch (e) {
      print('Error deleting activity: $e');
      // Handle error
    }
  }




  void _updateActivityStatus(Activity activity) async {
    DateTime currentDate = DateTime.now();
    String status = '';
    try {
      if (activity.endDate.isAfter(currentDate)) {
        // If endDate is after today's date, set status to 'Completed'
        status = 'Completed';
      } else {
        // If endDate is before today's date, set status to 'LateDone'
        status = 'LateDone';
      }
      await _activityCollection.doc(activity.id).update({'status': status});
      print('Activity status updated successfully!');
      setState(() {
        _fetchActivitiesFromFirestore();
      });
    } catch (e) {
      print('Error updating activity status in Firestore: $e');
    }
  }



  void _showAddActivityPopup(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();

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
                    decoration: InputDecoration(
                        labelText: 'Activity Description'),
                    controller: descriptionController,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Start Date and Time'),
                          onTap: () async {
                            final DateTime? pickedDateTime =
                            await _selectDateTime(
                                context, DateTime.now());
                            if (pickedDateTime != null) {
                              setState(() {
                                startDateController.text =
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(pickedDateTime);
                              });
                            }
                          },
                          controller: startDateController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'End Date and Time'),
                          onTap: () async {
                            final DateTime? pickedDateTime =
                            await _selectDateTime(
                                context, DateTime.now());
                            if (pickedDateTime != null) {
                              setState(() {
                                endDateController.text =
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(pickedDateTime);
                              });
                            }
                          },
                          controller: endDateController,
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

  void _addActivityToFirestore(String name, String description,
      String startDateStr, String endDateStr) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        DateTime startDate = DateTime.parse(startDateStr);
        DateTime endDate = DateTime.parse(endDateStr);

        String activityId = Uuid().v4(); // Generate a unique ID
        await _activityCollection.doc(activityId).set({
          'id': activityId, // Save the ID in Firestore
          'email': userEmail,
          'name': name,
          'description': description,
          'startDate': startDate,
          'endDate': endDate,
          'status' : "Pending",
        });

        setState(() {
          activities.add(Activity(
            id: activityId, // Pass the generated ID
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            status: "Pending",
          ));
        });
      } else {
        print('User email not found in SharedPreferences');
      }
    } catch (e) {
      print('Error adding activity to Firestore: $e');
    }
  }

  void _showActivityDetails(BuildContext context, Activity activity) async {
    TextEditingController nameController =
    TextEditingController(text: activity.name);
    TextEditingController descriptionController =
    TextEditingController(text: activity.description);
    TextEditingController startDateController =
    TextEditingController(text: _formatDate(activity.startDate));
    TextEditingController endDateController =
    TextEditingController(text: _formatDate(activity.endDate));

    DateTime? newStartDate;
    DateTime? newEndDate;

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
                  decoration: InputDecoration(
                      labelText: 'Activity Description'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startDateController,
                        decoration: InputDecoration(
                            labelText: 'Start Date and Time'),
                        onTap: () async {
                          newStartDate = await _selectDateTime(
                              context, activity.startDate);
                          if (newStartDate != null) {
                            setState(() {
                              activity.startDate = newStartDate!;
                              startDateController.text =
                                  _formatDate(newStartDate!);
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
                        decoration: InputDecoration(
                            labelText: 'End Date and Time'),
                        onTap: () async {
                          newEndDate = await _selectDateTime(
                              context, activity.endDate);
                          if (newEndDate != null) {
                            setState(() {
                              activity.endDate = newEndDate!;
                              endDateController.text =
                                  _formatDate(newEndDate!);
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
                  id: activity.id, // Pass the activity ID
                  name: nameController.text,
                  description: descriptionController.text,
                  startDate: activity.startDate,
                  endDate: activity.endDate,
                  status: "Pending",
                );
                _updateActivityInFirestore(updatedActivity); // Pass the updated activity
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        QuerySnapshot snapshot = await _activityCollection
            .where('email', isEqualTo: userEmail)
            .where('status', isEqualTo: 'Pending')
            .get();
        List<Activity> fetchedActivities = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Activity.fromMap(data); // Remove setting ID here
        }).toList();
        setState(() {
          activities = fetchedActivities;
        });
      } else {
        print('User email not found in SharedPreferences');
      }
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  void _updateActivityInFirestore(Activity activity) async {
    try {
      // Check if the document exists before updating
      await _activityCollection.doc(activity.id).update(activity.toMap());
      print('Activity updated successfully!');


    } catch (e) {
      print('Error updating activity in Firestore: $e');
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

  Future<DateTime?> _selectDateTime(BuildContext context, DateTime initialDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
class Activity {
  String id; // Firestore document ID
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String status; // New field for activity status

  Activity({
    required this.id, // Make the id parameter required
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status, // Initialize status
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'status': status, // Include status in the map
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'], // Get ID from Firestore
      name: map['name'],
      description: map['description'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'] ?? '', // Handle null status
    );
  }
}
