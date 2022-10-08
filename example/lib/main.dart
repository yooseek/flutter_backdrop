import 'package:flutter/material.dart';
import 'package:flutter_backdrop_bottom_slide/backdrop_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BackDropScreen(
        backgroundChild: FlutterLogo(),
        bottomChild: Container(
          height: 500,
          color: Colors.amber,
        ),
      ),
    );
  }
}