import 'package:flutter/material.dart';

void main() {
  runApp(const MalleeApp());
}

class MalleeApp extends StatelessWidget {
  const MalleeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mallee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to Mallee'),
        ),
      ),
    );
  }
}
