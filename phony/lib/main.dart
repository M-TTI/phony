import 'package:flutter/material.dart';
import 'package:phony/views/test_page.dart';

void main() {
  runApp(const PhonyApp());
}

class PhonyApp extends StatelessWidget {
  const PhonyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phony',
      home: const TestPage(title: 'Phony'),
    );
  }
}