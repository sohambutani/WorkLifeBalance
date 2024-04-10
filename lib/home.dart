import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklifebalance/login.dart';
import 'package:worklifebalance/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:worklifebalance/utils.dart';
import 'BMI.dart';
import 'goal.dart';
import 'health.dart';
import 'activity.dart';
import 'task.dart';
import 'event.dart';
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

class Home extends StatefulWidget {




  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> images = [
    'assets/first.png',
    'assets/second.png',
    'assets/third.png',
    'assets/fourth.png',
    'assets/fifth.png',
  ];

  String userName = ''; // Variable to hold user's name

  @override
  void initState() {
    super.initState();
    _getUserDetails(); // Fetch user details on initialization
  }

  Future<void> _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
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
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hii.., ',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'How is your work life balance?',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20), // Add padding after the thought
                    // Add remaining content here
                  ],
                ),
              ),
            ),


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
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 1,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 4,
                children: [
                  FeatureSquareWithText(
                    imagePath: 'assets/target.png',
                    title: 'Goal',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GoalPage()),
                      );
                    },
                  ),

                  FeatureSquareWithText(
                    imagePath: 'assets/heart.png',
                    title: 'BMI',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BMI()),
                      );
                    },
                  ),
                  FeatureSquareWithText(
                    imagePath: 'assets/clipboard.png',
                    title: 'Activity',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivityPage()),
                      );
                    },
                  ),
                  FeatureSquareWithText(
                    imagePath: 'assets/calendar.png',
                    title: 'Event',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: FutureBuilder(
          future: _getUserDetails(),
          builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Image.asset('assets/profile.png'), // Replace with user image
                        ),
                        SizedBox(height: 10),
                        Text(
                          snapshot.data!['userName']!, // Display user's username
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.person, color: Colors.black),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Text(
                          'Name: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${snapshot.data!['userName']!}',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Email: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${snapshot.data!['userEmail']!}',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.black),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      // Add functionality for settings tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.black),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      auth.signOut().then((value) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyLogin()));
                      }).onError((error, stackTrace) {
                        Utils().toastMessage(error.toString());
                      });
                      // Add logout functionality here
                    },
                  ),
                ],
              );
            } else {
              return Text('Error loading user details');
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, String>> _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName') ?? ''; // Return an empty string if username is null
    String userEmail = prefs.getString('userEmail') ?? ''; // Return an empty string if userEmail is null
    return {'userName': userName, 'userEmail': userEmail};
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
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                width: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
