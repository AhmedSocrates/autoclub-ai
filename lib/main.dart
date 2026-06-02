// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_club_ai/core/theme/app_theme.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:auto_club_ai/features/auth/repositories/user_repository.dart';
import 'package:auto_club_ai/features/settings/bloc/user/user_bloc.dart';
import 'package:auto_club_ai/features/settings/repository/user_profile_repository.dart';
import 'package:auto_club_ai/features/events/bloc/event_bloc.dart';
import 'package:auto_club_ai/features/events/bloc/event_detail_bloc.dart';
import 'package:auto_club_ai/features/events/repositories/event_repository.dart';
import 'package:auto_club_ai/features/tasks/bloc/task_bloc.dart';
import 'package:auto_club_ai/features/tasks/repositories/task_repository.dart';

import 'core/routing/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
try {
    await dotenv.load(fileName: ".env");
    print("✅ DOTENV SUCCESS: .env file loaded successfully!");
    print("🔑 GEMINI KEY FOUND: ${dotenv.env['GEMINI_API_KEY'] != null}");
  } catch (e) {
    print("❌ DOTENV CRITICAL ERROR: Could not load .env file! Details: $e");
  }
  try {
    // Fixed: Only initialize Firebase once!
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(" Firebase initialized successfully!");
  } catch (e) {
    print(" Firebase initialization failed: $e");
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => UserProfileRepository()),
        RepositoryProvider(create: (_) => EventRepository()),
        RepositoryProvider(create: (_) => TaskRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
            )..add(AppStarted()),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              userProfileRepository: context.read<UserProfileRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => EventBloc(
              eventRepository: context.read<EventRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => EventDetailBloc(
              eventRepository: context.read<EventRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TaskBloc(
              taskRepository: context.read<TaskRepository>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // We can read the AuthBloc here because the BlocProvider is now a parent of MyApp.
    // This ensures our router is initialized exactly once.
    _router = AppRouter.createRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AutoClub AI',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}