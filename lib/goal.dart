import

'package:flutter/material.dart';

class GoalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Goal Page'),
      ),
      body: Stack(
        children: [
          // Your other widgets can be added here
          Align(
            alignment: Alignment.center,
            child: Text(
              'My Goal',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
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
        ],
      ),
    );
  }

  void _shadowPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.3,
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
                    style: TextStyle(fontSize: 18),
                  ),
                  // Add more widgets as needed
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  }

