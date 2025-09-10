import 'package:flutter/material.dart';
import 'package:location_navigator/location_navigator.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Places'),
        ),
        body: const NearbyPlacesWidget(), // radius removed
      ),
    );
  }
}
