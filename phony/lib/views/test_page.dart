import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text(title))
      ],
    );
  }
}