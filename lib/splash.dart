import 'dart:async';
import 'package:flutter/material.dart';
import 'package:worklifebalance/home.dart';
import 'package:worklifebalance/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }
  Future<void> checkLoginStatus() async {
    WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('userEmail');
    print('User email from SharedPreferences: $userEmail');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => userEmail != null && userEmail.isNotEmpty
            ? Home() // User is already logged in
            : MyLogin(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // Set background color
      body: SafeArea(
        child: Container(
          color: Color.fromRGBO(32, 67, 93, 1.0),
          // You can keep the container if you need it for other purposes
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      //margin: EdgeInsets.only(bottom: 100),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 280,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
