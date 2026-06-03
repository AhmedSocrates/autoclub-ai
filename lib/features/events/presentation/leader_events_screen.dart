import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../bloc/events_cubit.dart';
import '../data/event_repository.dart';
import '../models/leader_event.dart';
import 'leader_event_detail_screen.dart';
import 'widgets/create_event_bottom_sheet.dart';

class LeaderEventsScreen extends StatelessWidget {
  const LeaderEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final leaderId =
        authState is Authenticated ? authState.user.userId : '';

    return BlocProvider(
      create: (_) => EventsCubit(
        repository: context.read<EventRepository>(),
        leaderId: leaderId,
      ),
      child: const _LeaderEventsView(),
    );
  }
}

class _LeaderEventsView extends StatelessWidget {
  const _LeaderEventsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<LeaderEvent>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: AppColors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const CreateEventBottomSheet(),
          );
          if (!context.mounted || result == null) return;
          // Save to Firestore (draft — NOT published to members yet)
          await context.read<EventsCubit>().addEvent(result);
        },
        child: const Icon(Icons.auto_awesome),
      ),
      body: BlocBuilder<EventsCubit, List<LeaderEvent>>(
        builder: (context, events) {
          if (events.isEmpty) return const _EmptyEventsState();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: events.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Divider(color: theme.colorScheme.outlineVariant),
                );
              }

              final event = events[index - 1];
              final dateLabel =
                  '${DateFormat.yMd().format(event.startDate)} – ${DateFormat.yMd().format(event.endDate)}';
              final metaLabel = '${event.assignedCount} assigned';

              return Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                child: Dismissible(
                  key: ValueKey(event.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete event?'),
                        content: Text('Remove "${event.name}" from the list?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.black,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) =>
                      context.read<EventsCubit>().deleteEvent(event.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: theme.colorScheme.onErrorContainer),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final updated =
                          await Navigator.of(context).push<LeaderEvent>(
                        MaterialPageRoute(
                          builder: (_) =>
                              LeaderEventDetailScreen(event: event),
                        ),
                      );
                      if (!context.mounted || updated == null) return;
                      context.read<EventsCubit>().updateEvent(updated);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: const Border.fromBorderSide(
                            BorderSide(color: AppColors.borderDark)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 16,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(dateLabel,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color:
                                                    AppColors.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  metaLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyEventsState extends StatelessWidget {
  const _EmptyEventsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note_outlined,
                size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 18),
            Text('No Events Yet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Tap the ✨ button to create your first event.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
