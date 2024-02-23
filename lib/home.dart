import 'package:flutter/material.dart';
import 'package:worklifebalance/notification.dart';
import 'goal.dart';
import 'health.dart';
import 'activity.dart';
import 'task.dart';
import 'calender.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hii, User'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()),
            );},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FeatureSquareWithText(
                    imagePath: 'assets/employee.png',
                    title: 'Goal Page',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GoalPage()),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: FeatureSquareWithText(
                    imagePath: 'assets/task-list.png',
                    title: 'Task Page',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FeatureSquareWithText(
                    imagePath: 'assets/healthcare.png',
                    title: 'Health Page',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HealthPage()),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: FeatureSquareWithText(
                    imagePath: 'assets/activity.png',
                    title: 'Activity Page',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FeatureSquareWithText(
                    imagePath: 'assets/deadline.png',
                    title: 'Calendar Page',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CalenderPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureSquareWithText extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  FeatureSquareWithText({
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 200,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
