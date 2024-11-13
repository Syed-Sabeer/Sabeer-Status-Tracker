import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Import generated Firebase configuration
import 'sabeer_side/homeview.dart'; // Your custom view
import 'parent_side/parenthomeview.dart'; // Another custom view in case you need it

void main() async {
  // Ensure Flutter binding is initialized before running Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options for your platform
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Pass the options here
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Set up which view to show depending on the logic, for now using HomeView
      home: ParentHomeView(), // You can replace it with ParentHomeView if needed
    );
  }
}
