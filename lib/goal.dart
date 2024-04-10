import 'package:flutter/material.dart';
import 'package:worklifebalance/home.dart';
import 'package:worklifebalance/statusGraph.dart';
import 'CompletedGoals.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GoalPage(),
    );
  }
}

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  List<Goal> goals = [];
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      FirebaseFirestore.instance
          .collection('goals')
          .where('userEmail', isEqualTo: userEmail)
          .where('status', isEqualTo: 'Pending')
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          goals = querySnapshot.docs.map((doc) {
            return Goal(
              id: doc.id,
              name: doc['name'],
              description: doc['description'],
              startDate: (doc['startDate'] as Timestamp).toDate(),
              endDate: (doc['endDate'] as Timestamp).toDate(),
              status: doc['status'],
            );
          }).toList();
        });
      }).catchError((error) {
        print('Error fetching goals: $error');
        // Handle error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal'),
        elevation: 8, // Add elevation for shadow
        backgroundColor: Colors.white, // Set background color to white
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showGoalDetails(context, goals[index]);
                  },
                  child: _buildGoalContainer(goals[index]),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                ); // Add functionality for home button
              },
            ),
            IconButton(
              icon: Icon(Icons.insert_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatusGraph()),
                );
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
              icon:  Icon(
                Icons.verified_rounded,

              ),
              onPressed: (

                  ) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoalStatusPage()),
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
            child: Image.asset(
              'assets/plus.png', // Path to your custom image file
              height: 45, // Adjust the height as needed
              width: 45, // Adjust the width as needed
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalAchievedPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Goal Achieved!'),
          content: Text('Congratulations! You have achieved your goal.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalContainer(Goal goal) {
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
                value: goal.isCompleted,
                onChanged: (value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm'),
                        content: Text('Are you sure you want to mark this goal as completed?'),
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
                                goal.isCompleted = value ?? false;
                              });
                              if (goal.isCompleted) {
                                _updateGoalStatus(goal);
                                _showGoalAchievedPopup(context);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                activeColor: goal.isCompleted ? Colors.green : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showGoalDetails(context, goal);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${goal.description}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start Date: ${_formatDate(goal.startDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'End Date: ${_formatDate(goal.endDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmation(context, goal);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to delete this goal?'),
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
                _deleteGoal(goal);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _deleteGoal(Goal goal) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(goal.id).delete();
      setState(() {
        goals.removeWhere((element) => element.id == goal.id);
      });
    } catch (e) {
      print('Error deleting goal: $e');
      // Handle error
    }
  }


  void _shadowPopup(BuildContext context) async {
    String goalName = '';
    String goalDescription = '';
    DateTime startDate = DateTime.now();
    DateTime? endDate; // Change type to DateTime?

    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

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
                          decoration: InputDecoration(labelText: 'Goal Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a goal name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            goalName = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Goal Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a goal description';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            goalDescription = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: startDateController,
                          decoration: InputDecoration(labelText: 'Start Date'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a start date';
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
                            if (pickedDate != null && pickedDate != startDate) {
                              setState(() {
                                startDate = pickedDate;
                                startDateController.text =
                                "${startDate.toLocal()}".split(' ')[0];
                                if (endDate == null) {
                                  // Set end date only if it hasn't been set already
                                  endDate = startDate.add(Duration(days: 1));
                                  endDateController.text =
                                  "${endDate!.toLocal()}".split(' ')[0];
                                }
                              });
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: endDateController,
                          decoration: InputDecoration(labelText: 'End Date'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an end date';
                            }
                            if (startDate.isAfter(endDate!)) {
                              return 'End date must be after start date';
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? startDate.add(Duration(days: 1)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null && pickedDate != endDate) {
                              setState(() {
                                endDate = pickedDate;
                                endDateController.text =
                                "${endDate!.toLocal()}".split(' ')[0];
                              });
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Goal newGoal = Goal(
                                id: Uuid().v4(), // Generate UUID for the goal ID
                                name: goalName,
                                description: goalDescription,
                                startDate: startDate,
                                endDate: endDate!,
                                status: 'Pending', // Add status argument
                              );

                              try {
                                await FirebaseFirestore.instance.collection('goals').add({
                                  'userEmail': userEmail,
                                  'name': newGoal.name,
                                  'description': newGoal.description,
                                  'startDate': newGoal.startDate,
                                  'endDate': newGoal.endDate,
                                  'status': 'Pending', // Set status to Pending by default
                                });
                                setState(() {
                                  goals.add(newGoal);
                                });
                                print('Goal Name: $goalName');
                                print('Goal Description: $goalDescription');
                                print('Start Date: $startDate');
                                print('End Date: $endDate');
                                Navigator.pop(context);
                              } catch (e) {
                                print('Error adding goal: $e');
                                // Handle error
                              }
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

  void _showGoalDetails(BuildContext context, Goal goal) async {
    TextEditingController nameController = TextEditingController(text: goal.name);
    TextEditingController descriptionController = TextEditingController(text: goal.description);
    TextEditingController startDateController = TextEditingController(text: _formatDate(goal.startDate));
    TextEditingController endDateController = TextEditingController(text: _formatDate(goal.endDate));

    DateTime? newStartDate;
    DateTime? newEndDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Goal',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Goal Name'),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Goal Description'),
                  ),
                  SizedBox(height: 10.0),
                  InkWell(
                    onTap: () async {
                      newStartDate = await _selectDate(context, goal.startDate);
                      if (newStartDate != null) {
                        setState(() {
                          goal.startDate = newStartDate!;
                          startDateController.text = _formatDate(newStartDate!);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: startDateController,
                        decoration: InputDecoration(labelText: 'Start Date'),
                        readOnly: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  InkWell(
                    onTap: () async {
                      newEndDate = await _selectDate(context, goal.endDate);
                      if (newEndDate != null) {
                        setState(() {
                          goal.endDate = newEndDate!;
                          endDateController.text = _formatDate(newEndDate!);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: endDateController,
                        decoration: InputDecoration(labelText: 'End Date'),
                        readOnly: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Goal updatedGoal = Goal(
                            id: goal.id,
                            name: nameController.text,
                            description: descriptionController.text,
                            startDate: newStartDate ?? goal.startDate,
                            endDate: newEndDate ?? goal.endDate,
                            status: 'Pending',
                          );
                          await _updateGoal(updatedGoal);
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      goal.name = nameController.text;
      goal.description = descriptionController.text;
      // Start and end dates remain unchanged
    });
  }

  Future<void> _updateGoal(Goal goal) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(goal.id).update({
        'name': goal.name,
        'description': goal.description,
        'startDate': goal.startDate,
        'endDate': goal.endDate,
      });
      int index = goals.indexWhere((element) => element.id == goal.id);
      if (index != -1) {
        setState(() {
          goals[index] = goal;
        });
      }
    } catch (e) {
      print('Error updating goal: $e');
      // Handle error
    }
  }

  void _updateGoalStatus(Goal goal) async {
    DateTime currentDate = DateTime.now();
    String status;

    if (goal.endDate.isAfter(currentDate)) {
      // If end date is after today's date, status is 'completed'
      status = 'Completed';
    } else if (goal.endDate.isBefore(currentDate)) {
      // If end date is before today's date, status is 'lateDone'
      status = 'LateDone';
    } else {
      // If end date is today, you may have a different handling
      status = 'Pending';
    }

    try {
      await FirebaseFirestore.instance.collection('goals').doc(goal.id).update({
        'status': status,
      });
      setState(() {
        goal.status = status;

      });
      _fetchGoals();
    } catch (e) {
      print('Error updating goal status: $e');
      // Handle error
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

class Goal {
  late String id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String status;
  bool isCompleted; // Add isCompleted property

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.isCompleted = false, // Initialize isCompleted to false by default
  });
}
