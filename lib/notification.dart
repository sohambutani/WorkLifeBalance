import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Stack(
        children: [
          // Your other widgets can be added here
          Align(
            alignment: Alignment.center,
            child: Text(
              'My Notification',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          // Positioned(
          //   bottom: 30,
          //   right: 30,
          //   child: Image.asset(
          //     'assets/square.png',
          //     height: 40,
          //     width: 40,
          //   ),
          // ),
        ],
      ),
    );
  }
}
