import 'package:flutter/material.dart';

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
        title: Text('Welcome to Goal Page'),
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  _shadowPopup(context);
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
    // Your existing code for showing the modal bottom sheet

    // Your existing code for showing the modal bottom sheet
    String goalName = '';
    String goalDescription = '';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();

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
                    'Details of your goal',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Goal Name'),
                    onChanged: (value) {
                      goalName = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Goal Description'),
                    onChanged: (value) {
                      goalDescription = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: startDateController,
                    decoration: InputDecoration(labelText: 'Start Date'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != startDate) {
                        startDate = pickedDate;
                        startDateController.text =
                        "${startDate.toLocal()}".split(' ')[0];
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: endDateController,
                    decoration: InputDecoration(labelText: 'End Date'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != endDate) {
                        endDate = pickedDate;
                        endDateController.text =
                        "${endDate.toLocal()}".split(' ')[0];
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Goal newGoal = Goal(
                        name: goalName,
                        description: goalDescription,
                        startDate: startDate,
                        endDate: endDate,
                      );
                      setState(() {
                        goals.add(newGoal);
                      });
                      print('Goal Name: $goalName');
                      print('Goal Description: $goalDescription');
                      print('Start Date: $startDate');
                      print('End Date: $endDate');
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
