// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// // TODO: Import your actual screens here once created
// // import '../../features/auth/presentation/login_screen.dart';
// // import '../../features/membership/presentation/dashboard_screen.dart';

// class AppRouter {
//   // Define route paths as constants to avoid typos
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String dashboard = '/dashboard';

//   static final GoRouter router = GoRouter(
//     initialLocation: login, // App starts here
    
//     // This redirect logic is perfect for your Sprint 1 Auth
//     redirect: (BuildContext context, GoRouterState state) {
//       // TODO: Replace with actual Firebase Auth check
//       const bool isLoggedIn = false; 
      
//       final bool isGoingToLogin = state.matchedLocation == login;
//       final bool isGoingToRegister = state.matchedLocation == register;

//       // If not logged in and not trying to login/register, send to login
//       if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
//         return login;
//       }
      
//       // If logged in and trying to access login screen, send to dashboard
//       if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
//         return dashboard;
//       }

//       return null; // No redirect needed
//     },

//     routes: <RouteBase>[
//       GoRoute(
//         path: login,
//         builder: (BuildContext context, GoRouterState state) {
//           return const Scaffold(body: Center(child: Text("Login Screen"))); // Replace with your LoginScreen()
//         },
//       ),
//       GoRoute(
//         path: register,
//         builder: (BuildContext context, GoRouterState state) {
//           return const Scaffold(body: Center(child: Text("Register Screen"))); // Replace with your RegisterScreen()
//         },
//       ),
//       GoRoute(
//         path: dashboard,
//         builder: (BuildContext context, GoRouterState state) {
//           return const Scaffold(body: Center(child: Text("Dashboard Screen"))); // Replace with your DashboardScreen()
//         },
//       ),
//     ],
//   );
// }