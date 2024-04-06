import 'package:flutter/material.dart';
import 'package:worklifebalance/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:worklifebalance/register.dart';
import 'package:worklifebalance/splash.dart';

import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());

}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      routes: {
        'register': (context) => MyRegister(),
        'login': (context) => MyLogin(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
  class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  backgroundColor: Colors.white,
  ),
  body: SplashScreen(),
  );
  }
}
