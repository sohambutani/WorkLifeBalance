import 'package:flutter/material.dart';
import 'package:worklifebalance/home.dart';
import 'home.dart';

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

  Widget _buildGoalContainer(Goal goal) {
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
        goal.name,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  void _shadowPopup(BuildContext context) {
    String goalName = '';
    String goalDescription = '';
    DateTime startDate = DateTime.now();
    DateTime? endDate; // Change type to DateTime?

    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();

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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Goal newGoal = Goal(
                                name: goalName,
                                description: goalDescription,
                                startDate: startDate,
                                endDate: endDate!,
                              );
                              setState(() {
                                goals.add(newGoal);
                              });
                              print('Goal Name: $goalName');
                              print('Goal Description: $goalDescription');
                              print('Start Date: $startDate');
                              print('End Date: $endDate');
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
        return AlertDialog(
          title: Text('Edit Goal'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Goal Name'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Goal Description'),
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 10),
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
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Goal updatedGoal = Goal(
                  name: nameController.text,
                  description: descriptionController.text,
                  startDate: newStartDate ?? goal.startDate,
                  endDate: newEndDate ?? goal.endDate,
                );
                Navigator.pop(context, updatedGoal);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    setState(() {
      goal.name = nameController.text;
      goal.description = descriptionController.text;
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

class Goal {
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;

  Goal({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}
