import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/events/bloc/event_detail_bloc.dart';
import 'package:auto_club_ai/features/events/bloc/event_detail_event.dart';
import 'package:auto_club_ai/features/events/bloc/event_detail_state.dart';
import 'package:auto_club_ai/features/events/presentation/widgets/event_info_card.dart';
import 'package:auto_club_ai/features/events/presentation/widgets/event_task_item.dart';
import 'package:auto_club_ai/core/models/event.dart';
import 'package:auto_club_ai/features/events/presentation/widgets/social_scheduler_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      context.read<EventDetailBloc>().add(LoadEventDetail(widget.eventId));

  void _openSocialScheduler(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialSchedulerSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailBloc, EventDetailState>(
      builder: (context, state) {
        final title = state is EventDetailLoaded
            ? state.event.name
            : 'Event Details';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
            actions: [
              if (state is EventDetailLoaded)
                IconButton(
                  icon: const Icon(Icons.campaign_outlined),
                  tooltip: 'Schedule Post',
                  onPressed: () => _openSocialScheduler(context, state.event),
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(EventDetailState state) {
    if (state is EventDetailLoading || state is EventDetailInitial) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    if (state is EventDetailError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textDisabled),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is EventDetailLoaded) {
      final pending = state.tasks.where((t) => !t.status).toList();
      final completed = state.tasks.where((t) => t.status).toList();

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Event info ─────────────────────────────────────────────
            EventInfoCard(event: state.event),

            const SizedBox(height: 12),

            // ── Scheduler Action Button ────────────────────────────────
            ElevatedButton.icon(
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Schedule Social Announcement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _openSocialScheduler(context, state.event),
            ),

            const SizedBox(height: 24),

            // ── Tasks header ───────────────────────────────────────────
            Row(
              children: [
                Text('Tasks', style: AppTextStyles.h3),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${state.tasks.length}',
                    style: AppTextStyles.label,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (state.tasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.checklist_outlined,
                        size: 40, color: AppColors.textDisabled),
                    const SizedBox(height: 8),
                    Text('No tasks for this event',
                        style: AppTextStyles.bodySm),
                  ],
                ),
              ),

            // ── Pending tasks ──────────────────────────────────────────
            if (pending.isNotEmpty) ...[
              _SectionLabel('Pending (${pending.length})'),
              ...pending.map((t) => EventTaskItem(task: t)),
            ],

            // ── Completed tasks ────────────────────────────────────────
            if (completed.isNotEmpty) ...[
              _SectionLabel('Completed (${completed.length})'),
              ...completed.map((t) => EventTaskItem(task: t)),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(letterSpacing: 0.8),
      ),
    );
  }
}
