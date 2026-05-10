// lib/core/routing/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Your Auth BLoC and States
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

// Screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/email_verification.dart';
import '../../features/membership/presentation/application_approvals_screen.dart';
import '../../features/membership/presentation/membership_application_screen.dart';

class AppRouter {
  // Define route paths as constants
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String apply = '/apply';
  static const String approvals = '/approvals';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: login,
      // This tells GoRouter to re-run the redirect logic EVERY TIME the BLoC emits a new state
      refreshListenable: GoRouterRefreshStream(authBloc.stream), 
      
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        
        // Define our location checks
        final bool isGoingToLogin = state.matchedLocation == login;
        final bool isGoingToRegister = state.matchedLocation == register;
        final bool isGoingToVerify = state.matchedLocation == verifyEmail;

        // Rule 1: Initial, Error, or Unauthenticated -> Send to Login
        if (authState is AuthInitial || authState is Unauthenticated || authState is AuthError) {
          if (!isGoingToLogin) return login;
        }

        // Rule 2: User wants to create an account -> Send to Register
        if (authState is AuthCreateAccount) {
          if (!isGoingToRegister) return register;
        }

        // Rule 3: User needs to verify email -> Send to Verification Screen
        if (authState is AwaitingEmailVerfication) {
          if (!isGoingToVerify) return verifyEmail;
        }

        // Rule 4: User is fully Authenticated -> Send inside the app
        if (authState is Authenticated) {
          // If they are trying to access Auth screens while logged in, redirect to the app
          if (isGoingToLogin || isGoingToRegister || isGoingToVerify) {
            return apply; // Send them to the dashboard/application screen
          }
        }

        return null; // No redirect needed
      },

      routes: <RouteBase>[
        // --- Sprint 1: Auth Routes ---
        GoRoute(
          path: login,
          builder: (context, state) => const Scaffold(body: Center(child: Text("Login Screen"))), // Replace with LoginScreen()
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const Scaffold(body: Center(child: Text("Register Screen"))), // Replace with RegisterScreen()
        ),
        GoRoute(
          path: verifyEmail,
          builder: (context, state) => const Scaffold(body: Center(child: Text("Verify Email Screen"))), // Replace with VerifyScreen()
        ),
        
        // --- Sprint 2: Membership Routes ---
        GoRoute(
          path: apply,
          builder: (context, state) => const MembershipApplicationScreen(), 
        ),
        GoRoute(
          path: approvals,
          builder: (context, state) => const ApplicationApprovalsScreen(), 
        ),
      ],
    );
  }
}

// --- HELPER CLASS ---
// This bridges standard Streams (used by BLoC) with Listenable (used by GoRouter)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}