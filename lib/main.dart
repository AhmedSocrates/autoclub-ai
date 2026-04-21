import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Import the generated options file
import 'firebase_options.dart'; 

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      // This tells Firebase to look at firebase_options.dart and pick 
      // the correct keys for Android, iOS, or Web depending on where it's running
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(" Firebase initialized successfully!");
  } catch (e) {
    print(" Firebase initialization failed: $e");
  }

  // 3. Run your app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoClub AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Replace this with your actual Login or Home screen
      home: const Scaffold(
        body: Center(child: Text("AutoClub AI Ready")),
      ),
    );
  }
}