import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialSchedulerSheet extends StatefulWidget {
  final EventModel event;

  const SocialSchedulerSheet({super.key, required this.event});

  @override
  State<SocialSchedulerSheet> createState() => _SocialSchedulerSheetState();
}

enum SchedulerState { idle, loading, success }

class _SocialSchedulerSheetState extends State<SocialSchedulerSheet> {
  late final TextEditingController _messageController;
  bool _scheduleForLater = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _facebookSelected = true;
  bool _telegramSelected = true;

  SchedulerState _currentState = SchedulerState.idle;

  @override
  void initState() {
    super.initState();
    // Pre-populate with realistic event announcement text
    final dateStr = DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(widget.event.date);
    _messageController = TextEditingController(
      text: '📢 Upcoming Event: ${widget.event.name}\n'
          '📍 Venue: ${widget.event.venue}\n'
          '📅 Date: $dateStr\n\n'
          '${widget.event.description}\n\n'
          'Join us for this exciting club event! See you there! 🚗💨',
    );
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() async {
    if (!_facebookSelected && !_telegramSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one social media channel'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    setState(() {
      _currentState = SchedulerState.loading;
    });

    // Simulate scheduling delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _currentState = SchedulerState.success;
      });
    }

    // Auto-dismiss bottom sheet after success sequence
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_scheduleForLater
              ? 'Post successfully scheduled for execution!'
              : 'Announcement successfully posted to channels!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard bottom sheet height adjustment for keyboard offset
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentState == SchedulerState.idle
            ? _buildForm()
            : _currentState == SchedulerState.loading
                ? _buildLoading()
                : _buildSuccess(),
      ),
    );
  }

  Widget _buildForm() {
    final dateFormatted = _selectedDate != null
        ? DateFormat('EEE, d MMM yyyy').format(_selectedDate!)
        : 'Select Date';
    final timeFormatted = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Select Time';

    return SingleChildScrollView(
      child: Column(
        key: const ValueKey('scheduler_form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ──────────────────────────────────────────────────────────
          Text('Social Media Scheduler', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Create and schedule an announcement post for this event.',
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: 20),

          // ── Channels Selector ──────────────────────────────────────────────
          Text('Share To', style: AppTextStyles.label.copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChannelChip(
                label: 'Facebook',
                iconWidget: _buildFacebookIcon(),
                isSelected: _facebookSelected,
                selectedColor: const Color(0xFF1877F2),
                onTap: () {
                  setState(() {
                    _facebookSelected = !_facebookSelected;
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildChannelChip(
                label: 'Telegram',
                iconWidget: _buildTelegramIcon(),
                isSelected: _telegramSelected,
                selectedColor: const Color(0xFF229ED9),
                onTap: () {
                  setState(() {
                    _telegramSelected = !_telegramSelected;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Message Box ────────────────────────────────────────────────────
          Text('Post Content', style: AppTextStyles.label.copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              hintText: 'Enter your announcement details here...',
              hintStyle: const TextStyle(color: AppColors.textDisabled),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),

          // ── Post Time Toggle ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule for Later',
                    style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _scheduleForLater
                        ? 'Post will be published at selected time'
                        : 'Post will be published immediately',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
              Switch(
                value: _scheduleForLater,
                onChanged: (val) {
                  setState(() {
                    _scheduleForLater = val;
                  });
                },
                activeThumbColor: AppColors.black,
                activeTrackColor: AppColors.border,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor: AppColors.surfaceLight,
              ),
            ],
          ),

          // ── Time Pickers (Visible only if schedule for later is active) ───
          if (_scheduleForLater) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dateFormatted,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_outlined, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              timeFormatted,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          // ── Action Buttons ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _scheduleForLater ? 'Schedule' : 'Post Now',
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      key: const ValueKey('scheduler_loading'),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _scheduleForLater ? 'Scheduling announcement...' : 'Publishing announcement...',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          const Text(
            'Connecting to Facebook and Telegram APIs',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Container(
      key: const ValueKey('scheduler_success'),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.green.shade800,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _scheduleForLater ? 'Scheduled Successfully' : 'Published Successfully',
            style: AppTextStyles.h2.copyWith(color: Colors.green.shade800),
          ),
          const SizedBox(height: 8),
          Text(
            _scheduleForLater
                ? 'Your post will go live automatically.'
                : 'Your post is now live on your channels.',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelChip({
    required String label,
    required Widget iconWidget,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : AppColors.border,
              width: 1.5,
            ),
            color: isSelected ? selectedColor.withValues(alpha: 0.06) : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? selectedColor : AppColors.textSecondary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, size: 16, color: selectedColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Official Facebook Logo ─────────────────────────────────────────────────
  Widget _buildFacebookIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.bottomCenter,
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          height: 1.2,
        ),
      ),
    );
  }

  // ── Official Telegram Logo ─────────────────────────────────────────────────
  Widget _buildTelegramIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF229ED9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: const Offset(-1, 0.5),
        child: Transform.rotate(
          angle: -0.2,
          child: const Icon(
            Icons.send,
            color: Colors.white,
            size: 13,
          ),
        ),
      ),
    );
  }
}
