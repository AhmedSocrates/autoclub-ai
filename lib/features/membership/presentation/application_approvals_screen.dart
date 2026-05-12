import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/approvals_bloc.dart';
import '../bloc/approvals_event.dart';
import '../bloc/approvals_state.dart';
import '../data/membership_repository.dart';

class ApplicationApprovalsScreen extends StatelessWidget {
  const ApplicationApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MembershipRepository();
    return BlocProvider(
      create: (_) => ApprovalsBloc(repository: repository)
        ..add(FetchPendingApplications()),
      child: _ApprovalsView(repository: repository),
    );
  }
}

class _ApprovalsView extends StatelessWidget {
  final MembershipRepository repository;
  const _ApprovalsView({required this.repository});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isLeader =
        authState is Authenticated && authState.user.role == 'leader';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals Dashboard'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Registration toggle (leader only) ──────────────────────
          if (isLeader) _RegistrationToggle(repository: repository),

          // ── Pending applications list ──────────────────────────────
          Expanded(
            child: BlocBuilder<ApprovalsBloc, ApprovalsState>(
              builder: (context, state) {
                if (state is ApprovalsInitial || state is ApprovalsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ApprovalsError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<ApprovalsBloc>()
                        .add(FetchPendingApplications()),
                  );
                }

                if (state is ApprovalsLoaded) {
                  final apps = state.pendingApplications;
                  if (apps.isEmpty) return _EmptyView();
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: apps.length,
                    itemBuilder: (context, index) =>
                        _ApplicationCard(application: apps[index]),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Registration Toggle ──────────────────────────────────────────────────────

class _RegistrationToggle extends StatelessWidget {
  final MembershipRepository repository;
  const _RegistrationToggle({required this.repository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: repository.getRegistrationStatus(),
      builder: (context, snapshot) {
        final isOpen = snapshot.data ?? false;
        final colorScheme = Theme.of(context).colorScheme;
        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SwitchListTile(
            value: isOpen,
            onChanged: (value) async {
              try {
                await repository.toggleRegistration(value);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            secondary: Icon(
              isOpen ? Icons.lock_open_outlined : Icons.lock_outlined,
              color: isOpen ? colorScheme.primary : colorScheme.outline,
            ),
            title: Text(
              'Open Recruitment',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              isOpen
                  ? 'Applications are currently being accepted'
                  : 'Applications are currently closed',
            ),
          ),
        );
      },
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 72, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No pending applications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uid = application['uid'] as String? ?? '';
    final name = application['userName'] as String? ?? 'Unknown';
    final committee = application['committee'] as String? ?? 'N/A';
    final position = application['position'] as String? ?? 'N/A';
    final whyPosition = application['whyPosition'] as String? ?? '';
    final experience = application['experience'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + committee · position
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$committee  ·  $position',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (whyPosition.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Why this position',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(whyPosition,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],

            if (experience.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Experience',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(experience,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _decide(context, uid, false),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _decide(context, uid, true),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _decide(BuildContext context, String uid, bool isApproved) {
    context.read<ApprovalsBloc>().add(
          DecideApplicationEvent(studentId: uid, isApproved: isApproved),
        );
  }
}
