import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '아무거나',
      home: HomeScreen(),
    );
  }
}
