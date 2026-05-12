import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../data/membership_repository.dart';

class MembershipStatusScreen extends StatelessWidget {
  const MembershipStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MembershipRepository();
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.userId : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: repository.getApplicationStatus(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final application = snapshot.data;
          if (application == null) {
            return _buildNoApplicationView(context);
          }
          return _buildPendingView(context, application);
        },
      ),
    );
  }

  Widget _buildPendingView(
      BuildContext context, Map<String, dynamic> application) {
    final colorScheme = Theme.of(context).colorScheme;
    final committee = application['committee'] as String? ?? 'N/A';
    final position = application['position'] as String? ?? 'N/A';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top_rounded,
                size: 80, color: colorScheme.tertiary),
            const SizedBox(height: 24),
            Text(
              'Application Under Review',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your application is being reviewed by the club leadership. You will be notified once a decision has been made.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(label: 'Committee', value: committee),
                    const Divider(height: 20),
                    _DetailRow(label: 'Position', value: position),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoApplicationView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined,
                size: 80, color: colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              'No Application Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your application may have been processed. The app will redirect you automatically.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
