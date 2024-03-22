import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> task = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Task Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: task.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showTaskDetails(context, task[index]);
                  },
                  child: _buildTaskContainer(task[index]),
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

  Widget _buildTaskContainer(Task task) {
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
        task.name,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  void _shadowPopup(BuildContext context) {
    // Your existing code for showing the modal bottom sheet

    // Your existing code for showing the modal bottom sheet
    String taskName = '';
    String taskDescription = '';
    String taskPriority = '';
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
                    'Details of your task',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'task Name'),
                    onChanged: (value) {
                      taskName = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Task Description'),
                    onChanged: (value) {
                      taskDescription = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Task Priority'),
                    onChanged: (value) {
                      taskPriority = value;
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
                      Task newTask = Task(
                        name: taskName,
                        description: taskDescription,
                        priority: taskPriority,
                        startDate: startDate,
                        endDate: endDate,
                      );
                      setState(() {
                        task.add(newTask);
                      });
                      print('Task Name: $taskName');
                      print('Task Description: $taskDescription');
                      print('Task Priority: $taskPriority');
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

  void _showTaskDetails(BuildContext context, Task task) async {
    TextEditingController nameController = TextEditingController(text: task.name);
    TextEditingController descriptionController = TextEditingController(text: task.description);
    TextEditingController priorityController = TextEditingController(text: task.priority);
    TextEditingController startDateController = TextEditingController(text: _formatDate(task.startDate));
    TextEditingController endDateController = TextEditingController(text: _formatDate(task.endDate));

    DateTime? newStartDate;
    DateTime? newEndDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Task Description'),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    newStartDate = await _selectDate(context, task.startDate);
                    if (newStartDate != null) {
                      setState(() {
                        task.startDate = newStartDate!;
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
                    newEndDate = await _selectDate(context, task.endDate);
                    if (newEndDate != null) {
                      setState(() {
                        task.endDate = newEndDate!;
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
                Task updatedGoal = Task(
                  name: nameController.text,
                  description: descriptionController.text,
                  priority: priorityController.text,
                  startDate: newStartDate ?? task.startDate,
                  endDate: newEndDate ?? task.endDate,
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
      task.name = nameController.text;
      task.description = descriptionController.text;
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

class Task {
  String name;
  String description;
  String priority;
  DateTime startDate;
  DateTime endDate;

  Task({
    required this.name,
    required this.description,
    required this.priority,
    required this.startDate,
    required this.endDate,
  });
}
