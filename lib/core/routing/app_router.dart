import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// BLoC
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

// Auth wrapper
import '../../wrappers/auth_wrapper.dart';

// Membership screens
import '../../features/membership/presentation/application_approvals_screen.dart';
import '../../features/membership/presentation/membership_application_screen.dart';
import '../../features/membership/presentation/membership_status_screen.dart';

// Shell + member screens
import '../navigation/main_navigation_shell.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/events/presentation/screens/add_event_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/leader_events_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRouter {
  // ── Route path constants ───────────────────────────────────────────────────
  static const String auth             = '/auth';
  static const String apply            = '/apply';
  static const String membershipStatus = '/membership-status';
  static const String approvals        = '/approvals';
  static const String dashboard        = '/dashboard';
  static const String myTasks          = '/my-tasks';
  static const String events           = '/events';
  static const String settings         = '/settings';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: auth,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;

        // ── Auth-owned states → AuthWrapper handles them internally ───────────
        if (authState is AuthInitial ||
            authState is AuthLoading ||
            authState is Unauthenticated ||
            authState is AuthError ||
            authState is AuthCreateAccount ||
            authState is AwaitingEmailVerfication ||
            authState is PasswordReset ||
            authState is PasswordResetLoading ||
            authState is PasswordResetEmailSent) {
          if (loc != auth) return auth;
          return null;
        }

        // ── Authenticated — role-based routing ────────────────────────────────
        if (authState is Authenticated) {
          final role = authState.user.role;

          if (loc == auth) {
            if (role == 'member' || role == 'leader') return dashboard;
            if (role == 'pending') return membershipStatus;
            return apply;
          }

          if (role == 'member' || role == 'leader') {
            if (loc == apply || loc == membershipStatus) return dashboard;
            if (loc == approvals && role != 'leader') return dashboard;
            return null;
          }

          if (role == 'pending') {
            if (loc != membershipStatus) return membershipStatus;
            return null;
          }

          if (loc != apply) return apply;
          return null;
        }

        return null;
      },

      routes: <RouteBase>[
        // ── Auth (owned by AuthWrapper + AuthBloc) ────────────────────────────
        GoRoute(path: auth, builder: (_, _) => const AuthWrapper()),

        // ── Guest / Applicant Routes ──────────────────────────────────────────
        GoRoute(path: apply,            builder: (_, _) => const MembershipApplicationScreen()),
        GoRoute(path: membershipStatus, builder: (_, _) => const MembershipStatusScreen()),

        // ── Admin Route (leader only) ─────────────────────────────────────────
        GoRoute(path: approvals, builder: (_, _) => const ApplicationApprovalsScreen()),

        // ── Member / Leader Shell (persistent bottom nav) ─────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainNavigationShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: dashboard, builder: (_, _) => const DashboardScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: myTasks,
                builder: (context, _) {
                  final state = authBloc.state;
                  if (state is Authenticated && state.user.role == 'leader') {
                    return const LeaderEventsScreen();
                  }
                  return const TasksScreen();
                },
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: events,
                builder: (_, _) => const EventsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (_, _) => const AddEventScreen(),
                  ),
                  GoRoute(
                    path: 'event/:eventId',
                    builder: (context, state) => EventDetailScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: settings, builder: (_, _) => const SettingsScreen()),
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
