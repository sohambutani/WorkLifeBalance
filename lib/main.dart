import 'dart:io';
import 'package:flutter/material.dart';
import 'package:worklifebalance/firebase_options.dart';
import 'package:worklifebalance/register.dart';
import 'package:worklifebalance/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid ? await Firebase.initializeApp(
    // options: FirebaseOptions(
    //   apiKey: "AIzaSyDO54E8QotURJHYbFMK7N9e-UCsam-Kvt0",
    //   appId: "1:990044424268:android:6de2a7d0c61135e302cce9",
    //   messagingSenderId: "990044424268",
    //   projectId: "work-life-balance-7d93b",
    // ),
    options: DefaultFirebaseOptions.currentPlatform,
    )
 : await Firebase.initializeApp();
  runApp(MaterialApp(debugShowCheckedModeBanner: false,
    home: MyLogin(),
    routes: {
      'register': (context) => MyRegister(),
      'login': (context) => MyLogin(),
    },
  ));
}



