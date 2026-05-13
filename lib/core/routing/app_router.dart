import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// BLoC
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

// Auth screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/email_verification.dart';

// Membership screens
import '../../features/membership/presentation/application_approvals_screen.dart';
import '../../features/membership/presentation/membership_application_screen.dart';
import '../../features/membership/presentation/membership_status_screen.dart';

// Shell + member screens
import '../navigation/main_navigation_shell.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/social/presentation/social_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRouter {
  // ── Route path constants ───────────────────────────────────────────────────
  static const String login           = '/login';
  static const String register        = '/register';
  static const String verifyEmail     = '/verify-email';
  static const String apply           = '/apply';
  static const String membershipStatus = '/membership-status';
  static const String approvals       = '/approvals';
  static const String dashboard       = '/dashboard';
  static const String myTasks         = '/my-tasks';
  static const String social          = '/social';
  static const String settings        = '/settings';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;

        final isOnAuthScreen =
            loc == login || loc == register || loc == verifyEmail;

        if (authState is AuthInitial ||
            authState is Unauthenticated ||
            authState is AuthError) {
          if (loc != login) return login;
          return null;
        }

        // ── Rule 2: Creating account → register ────────────────────────────
        if (authState is AuthCreateAccount) {
          if (loc != register) return register;
          return null;
        }

        // ── Rule 3: Awaiting email verification → verify screen ────────────
        if (authState is AwaitingEmailVerfication) {
          if (loc != verifyEmail) return verifyEmail;
          return null;
        }

        // ── Rule 4: Authenticated — role-based routing ─────────────────────
        if (authState is Authenticated) {
          final role = authState.user.role;

          // Always redirect off auth screens once logged in
          if (isOnAuthScreen) {
            if (role == 'member' || role == 'leader') return dashboard;
            if (role == 'pending') return membershipStatus;
            return apply; // student / rejected
          }

          // Member / Leader: full app access; block guest-only routes
          if (role == 'member' || role == 'leader') {
            if (loc == apply || loc == membershipStatus) return dashboard;
            // Only leaders may visit /approvals
            if (loc == approvals && role != 'leader') return dashboard;
            return null;
          }

          // Pending: locked to the status screen
          if (role == 'pending') {
            if (loc != membershipStatus) return membershipStatus;
            return null;
          }

          // Student / Rejected: locked to the apply screen
          if (loc != apply) return apply;
          return null;
        }

        return null;
      },

      routes: <RouteBase>[
        // ── Auth Routes ────────────────────────────────────────────────────
        GoRoute(path: login,      builder: (_, __) => LoginScreen()),
        GoRoute(path: register,   builder: (_, __) => SignupScreen()),
        GoRoute(path: verifyEmail, builder: (_, __) => EmailVerificationScreen()),

        // ── Guest / Applicant Routes ───────────────────────────────────────
        GoRoute(path: apply,           builder: (_, __) => const MembershipApplicationScreen()),
        GoRoute(path: membershipStatus, builder: (_, __) => const MembershipStatusScreen()),

        // ── Admin Route (leader only, reached via Settings) ────────────────
        GoRoute(path: approvals, builder: (_, __) => const ApplicationApprovalsScreen()),

        // ── Member / Leader Shell (persistent bottom nav) ──────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainNavigationShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: dashboard, builder: (_, __) => const DashboardScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: myTasks, builder: (_, __) => const TasksScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: social, builder: (_, __) => const SocialScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
            ]),
          ],
        ),
      ],
    );
  }
}

// Bridges BLoC streams with GoRouter's Listenable interface
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
