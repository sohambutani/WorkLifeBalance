import 'package:flutter/material.dart';
import 'Screens/input_page.dart';

void main() => runApp(BMI());

class BMI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: InputPage(),
    );
  }
}
