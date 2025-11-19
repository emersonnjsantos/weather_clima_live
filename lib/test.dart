import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyApp && 
           other.runtimeType == runtimeType &&
           other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test App'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}