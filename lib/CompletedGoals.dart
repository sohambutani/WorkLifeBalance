import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

class GoalStatusPage extends StatefulWidget {
  @override
  _GoalStatusPageState createState() => _GoalStatusPageState();
}

class _GoalStatusPageState extends State<GoalStatusPage> {
  List<Goal> goals = [];

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
          .where('status', whereIn: ['Completed', 'LateDone'])
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
                return _buildGoalContainer(goals[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalContainer(Goal goal) {
    Color containerColor = Colors.white;


    containerColor = Colors.white;


    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black, // Border color
          width: 2, // Border width
        ),
        color: containerColor,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                  goal.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),

              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: goal.status == 'Completed' ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Text(
                  goal.status == 'Completed' ? 'Completed' : 'LateCompleted',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),
          Text(
            'Description: ${goal.description}',
            style: TextStyle(fontSize: 18, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date: ${_formatDate(goal.startDate)}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              Text(
                'End Date: ${_formatDate(goal.endDate)}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
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

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}
