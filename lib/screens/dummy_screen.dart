import 'package:flutter/material.dart';

class DummyScreen extends StatelessWidget {
  final String title;

  const DummyScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF31135F),
      ),
      body: Center(
        child: Text('This is the $title Screen'),
      ),
    );
  }
}