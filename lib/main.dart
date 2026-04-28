import 'package:auto_club_ai/core/theme/app_theme.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:auto_club_ai/features/auth/repositories/user_repository.dart';
import 'package:auto_club_ai/wrappers/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
          userRepository: context.read<UserRepository>()
          )..add(AppStarted()),
        child: MaterialApp(
          title: 'AutoClub AI',
          theme: AppTheme.lightTheme,
          
          home: AuthWrapper(),
        ),
      ),
    );
  }
}