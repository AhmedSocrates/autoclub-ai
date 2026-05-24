import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/leader_event.dart';
import 'edit_task_sheet.dart';

class CreateEventBottomSheet extends StatefulWidget {
  const CreateEventBottomSheet({super.key});

  @override
  State<CreateEventBottomSheet> createState() => _CreateEventBottomSheetState();
}

class _CreateEventBottomSheetState extends State<CreateEventBottomSheet> {
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<LeaderEventTask> _tasks = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _startDate != null &&
      _endDate != null &&
      !_endDate!.isBefore(_startDate!);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Lab',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manual task generation (no AI yet)',
                        style: TextStyle(fontSize: 12),
                      ),
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
                color: AppColors.accentGold.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
                border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.borderDark),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Event',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Enter the event details and add tasks manually for your team.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Event Name', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g., SUSKOM Annual Meeting...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start date',
                    date: _startDate,
                    onPick: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 5),
                        initialDate: _startDate ?? now,
                      );
                      if (picked == null) return;
                      setState(() {
                        _startDate = picked;
                        _endDate ??= picked;
                        if (_endDate!.isBefore(_startDate!)) {
                          _endDate = _startDate;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'End date',
                    date: _endDate,
                    onPick: () async {
                      final now = DateTime.now();
                      final base = _startDate ?? _endDate ?? now;
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 5),
                        initialDate: base,
                      );
                      if (picked == null) return;
                      setState(() {
                        _endDate = picked;
                        _startDate ??= picked;
                        if (_endDate!.isBefore(_startDate!)) {
                          _startDate = _endDate;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('Tasks', style: theme.textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final newTask = await showModalBottomSheet<LeaderEventTask>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => const EditTaskSheet(),
                    );
                    if (newTask == null) return;
                    setState(() => _tasks.add(newTask));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_tasks.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  itemCount: _tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      title: Text(task.title),
                      subtitle: Text(
                        task.assigneeNames.isEmpty
                            ? 'Unassigned'
                            : task.assigneeNames.join(', '),
                      ),
                      trailing: IconButton(
                        onPressed: () => setState(() => _tasks.removeAt(index)),
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSubmit
                    ? () {
                        final event = LeaderEvent(
                          id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
                          name: _nameController.text.trim(),
                          startDate: _startDate!,
                          endDate: _endDate!,
                          tasks: List.unmodifiable(_tasks),
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
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  const _DateField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = date == null ? 'Pick date' : DateFormat.yMd().format(date!);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: this.label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
