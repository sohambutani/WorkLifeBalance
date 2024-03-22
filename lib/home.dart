import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:worklifebalance/notification.dart';
import 'goal.dart';
import 'health.dart';
import 'activity.dart';
import 'task.dart';
import 'calender.dart';
import 'register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      theme: ThemeData(
        primaryColor: Colors.deepPurple, // Set your desired primary color
        hintColor: Colors.deepPurpleAccent, // Set your desired accent color
      ),
    );
  }
}

class Home extends StatelessWidget {
  final List<String> images = [
    'assets/first.png',
    'assets/second.png',
    'assets/third.png',
    'assets/fourth.png',
    'assets/fifth.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, User'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CarouselSlider(
            items: images.map((image) {
              return Image.asset(
                image,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              );
            }).toList(),
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 1.0, // Set to 1.0 for full width
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  FeatureSquareWithText(
                    imagePath: 'assets/employee.png',
                    title: 'Goal Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GoalPage()),
                      );
                    },
                  ),
                  FeatureSquareWithText(
                    imagePath: 'assets/task-list.png',
                    title: 'Task Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskPage()),
                      );
                    },
                  ),
                  FeatureSquareWithText(
                    imagePath: 'assets/healthcare.png',
                    title: 'Health Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HealthPage()),
                      );
                    },
                  ),
                  FeatureSquareWithText(
                    imagePath: 'assets/activity.png',
                    title: 'Activity Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivityPage()),
                      );
                    },
                  ),
                  FeatureSquareWithText(
                    imagePath: 'assets/deadline.png',
                    title: 'Calendar Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalenderPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
