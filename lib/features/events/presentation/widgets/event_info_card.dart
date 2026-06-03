import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  final EventModel event;

  const EventInfoCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final isSoon = daysUntil >= 0 && daysUntil <= 7;
    final isPast = event.date.isBefore(DateTime.now());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status chip ────────────────────────────────────────────────
          if (isSoon || isPast)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPast ? AppColors.surfaceLight : AppColors.accentGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPast ? 'Past Event' : 'Coming Soon',
                  style: AppTextStyles.label.copyWith(
                    color: isPast ? AppColors.textSecondary : AppColors.black,
                  ),
                ),
              ),
            ),

          // ── Date ────────────────────────────────────────────────────────
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(event.date),
            color: isSoon ? AppColors.accentOrange : AppColors.textSecondary,
          ),

          const SizedBox(height: 10),

          // ── Venue ────────────────────────────────────────────────────────
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: event.venue,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // ── Description ──────────────────────────────────────────────────
          Text('About', style: AppTextStyles.label.copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(
            event.description,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
