import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../bloc/create_event_cubit.dart';
import '../../models/leader_event.dart';
import 'edit_task_sheet.dart';

class CreateEventBottomSheet extends StatelessWidget {
  const CreateEventBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateEventCubit(),
      child: const _CreateEventView(),
    );
  }
}

class _CreateEventView extends StatelessWidget {
  const _CreateEventView();

  // Keep a single controller alive for the sheet's lifetime via a field on
  // the nearest StatefulElement — here we use a lightweight approach with
  // a controller stored inside an InheritedWidget-free StatefulWidget shell.
  @override
  Widget build(BuildContext context) {
    return const _CreateEventForm();
  }
}

class _CreateEventForm extends StatefulWidget {
  const _CreateEventForm();

  @override
  State<_CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<_CreateEventForm> {
  // TextEditingController is a platform resource that must be disposed —
  // keeping it here is correct; all business state lives in CreateEventCubit.
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 4,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocBuilder<CreateEventCubit, CreateEventState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppColors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Lab',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Manual task generation (no AI yet)',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: const Border.fromBorderSide(
                        BorderSide(color: AppColors.borderDark)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create Event',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text(
                        'Enter the event details and add tasks manually for your team.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Event name ───────────────────────────────────────────
                Text('Event Name', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., SUSKOM Annual Meeting...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: context.read<CreateEventCubit>().nameChanged,
                ),
                const SizedBox(height: 12),

                // ── Date pickers ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Start date',
                        date: state.startDate,
                        onPick: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                            initialDate: state.startDate ?? now,
                          );
                          if (picked == null || !context.mounted) return;
                          context.read<CreateEventCubit>().setStartDate(picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: 'End date',
                        date: state.endDate,
                        onPick: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                            initialDate:
                                state.endDate ?? state.startDate ?? now,
                          );
                          if (picked == null || !context.mounted) return;
                          context.read<CreateEventCubit>().setEndDate(picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Tasks ────────────────────────────────────────────────
                Row(
                  children: [
                    Text('Tasks', style: theme.textTheme.labelLarge),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final newTask =
                            await showModalBottomSheet<LeaderEventTask>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => EditTaskSheet(
                                eventEndDate: state.endDate,
                              ),
                        );
                        if (newTask == null || !context.mounted) return;
                        context.read<CreateEventCubit>().addTask(newTask);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (state.tasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      itemCount: state.tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: theme.colorScheme.outlineVariant),
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            task.assigneeNames.isEmpty
                                ? 'Unassigned'
                                : task.assigneeNames.join(', '),
                          ),
                          trailing: IconButton(
                            onPressed: () => context
                                .read<CreateEventCubit>()
                                .removeTask(index),
                            icon: const Icon(Icons.delete_outline),
                            color: theme.colorScheme.error,
                            tooltip: 'Remove',
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // ── Submit ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.canSubmit
                        ? () {
                            final event = LeaderEvent(
                              id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
                              name: state.name.trim(),
                              startDate: state.startDate!,
                              endDate: state.endDate!,
                              tasks: List.unmodifiable(state.tasks),
                            );
                            Navigator.of(context).pop(event);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.surfaceLight,
                      disabledForegroundColor: AppColors.textDisabled,
                    ),
                    child: const Text('Create Event'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  const _DateField({required this.label, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = date == null ? 'Pick date' : DateFormat.yMd().format(date!);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(display),
          ],
        ),
      ),
    );
  }
}
