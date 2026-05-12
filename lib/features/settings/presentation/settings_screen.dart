import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/routing/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isLeader = user?.role == 'leader';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ── Profile Section ──────────────────────────────────────
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const Divider(),

          // ── General ──────────────────────────────────────────────
          _SectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Coming in Sprint 3'),
            trailing: const Icon(Icons.chevron_right),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Appearance'),
            subtitle: const Text('Coming in Sprint 3'),
            trailing: const Icon(Icons.chevron_right),
            enabled: false,
          ),

          // ── Admin (leader only) ───────────────────────────────────
          if (isLeader) ...[
            const Divider(),
            _SectionHeader('Admin'),
            ListTile(
              leading: Icon(
                Icons.admin_panel_settings_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Approvals Dashboard'),
              subtitle: const Text('Review pending applications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppRouter.approvals),
            ),
          ],

          const Divider(),

          // ── Sign Out ──────────────────────────────────────────────
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              'Sign Out',
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () => context.read<AuthBloc>().add(SignOutRequested()),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
