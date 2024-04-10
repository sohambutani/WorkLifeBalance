import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklifebalance/activity.dart'; // Assuming you have an Activity class defined

class ActivityStatusPage extends StatefulWidget {
  @override
  _ActivityStatusPageState createState() => _ActivityStatusPageState();
}

class _ActivityStatusPageState extends State<ActivityStatusPage> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      FirebaseFirestore.instance
          .collection('activities')
          .where('email', isEqualTo: userEmail)
          .where('status', whereIn: ['Completed', 'LateDone'])
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          activities = querySnapshot.docs.map((doc) {
            return Activity(
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
        print('Error fetching activities: $error');
        // Handle error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity History'),
        elevation: 8, // Add elevation for shadow
        backgroundColor: Colors.white, // Set background color to white
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return _buildActivityContainer(activities[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContainer(Activity activity) {
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
                activity.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activity.status == 'Completed' ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Text(
                  activity.status == 'Completed' ? 'Completed' : 'LateCompleted',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Description: ${activity.description}',
            style: TextStyle(fontSize: 18, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date: ${_formatDateTime(activity.startDate)}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                'End Date: ${_formatDateTime(activity.endDate)}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)}  Time: ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute}';
  }
}
