import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/leader_event.dart';

class PriorityPill extends StatelessWidget {
  final LeaderTaskPriority priority;
  const PriorityPill({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, bg, fg) = switch (priority) {
      LeaderTaskPriority.high => (
          'High',
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        ),
      LeaderTaskPriority.medium => (
          'Med',
          AppColors.accentGold.withOpacity(0.25),
          AppColors.black,
        ),
      LeaderTaskPriority.low => (
          'Low',
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
