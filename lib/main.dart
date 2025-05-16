import 'package:flutter/material.dart';
import 'pages/profile.dart';
import 'pages/home.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHome(),
    initialRoute: '/Home',
    routes: {
      '/Home': (context) => MyHome(),
      '/profile': (context) => MyProfile(),
    },
  ));
}
