import 'package:flutter/material.dart';
import 'MainPage.dart';

void main() {
  runApp(MetroApp());
}

class MetroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
  }
}
