import 'package:flutter/material.dart';
import 'package:worklifebalance/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasksFromFirestore();
  }

  void _fetchTasksFromFirestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('userEmail', isEqualTo: userEmail)
            .get();

        List<Task> fetchedTasks = querySnapshot.docs.map((doc) {
          return Task(
            name: doc['name'],
            description: doc['description'],
            priority: doc['priority'],
            startDate: (doc['startDate'] as Timestamp).toDate(),
            endDate: (doc['endDate'] as Timestamp).toDate(),
          );
        }).toList();

        setState(() {
          tasks = fetchedTasks;
        });
      } catch (e) {
        print('Error fetching tasks: $e');
        // Handle error
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
        elevation: 8,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showTaskDetails(context, tasks[index]);
                  },
                  child: _buildTaskContainer(tasks[index]),
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
                  MaterialPageRoute(builder: (context) => Home()),
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
          _shadowPopup(context);
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
            child: Image.asset(
              'assets/plus.png',
              height: 45,
              width: 45,
            ),
          ),
        ),
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
                    decoration: InputDecoration(labelText: 'Task Name'),
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
                        startDateController.text = "${startDate.toLocal()}".split(' ')[0];
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
                        endDateController.text = "${endDate.toLocal()}".split(' ')[0];
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
                      _addTaskToFirestore(newTask);
                      setState(() {
                        tasks.add(newTask);
                      });
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
                TextFormField(
                  controller: priorityController,
                  decoration: InputDecoration(labelText: 'Task Priority'),
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
                Task updatedTask = Task(
                  name: nameController.text,
                  description: descriptionController.text,
                  priority: priorityController.text,
                  startDate: newStartDate ?? task.startDate,
                  endDate: newEndDate ?? task.endDate,
                );
                _updateTaskInFirestore(updatedTask);
                Navigator.pop(context, updatedTask);
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
      task.priority = priorityController.text;
    });
  }

  void _addTaskToFirestore(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      try {
        await FirebaseFirestore.instance.collection('tasks').add({
          'userEmail': userEmail,
          'name': task.name,
          'description': task.description,
          'priority': task.priority,
          'startDate': task.startDate,
          'endDate': task.endDate,
        });
      } catch (e) {
        print('Error adding task: $e');
        // Handle error
      }
    }
  }

  void _updateTaskInFirestore(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('userEmail', isEqualTo: userEmail)
            .where('name', isEqualTo: task.name) // Assuming name is unique
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({
              'description': task.description,
              'priority': task.priority,
              'startDate': task.startDate,
              'endDate': task.endDate,
            });
          });
        });
      } catch (e) {
        print('Error updating task: $e');
        // Handle error
      }
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
