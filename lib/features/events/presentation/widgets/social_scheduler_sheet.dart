import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/telegram_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../social/data/social_repository.dart';
import '../../../social/models/scheduled_post.dart';

class SocialSchedulerSheet extends StatefulWidget {
  final EventModel event;

  const SocialSchedulerSheet({super.key, required this.event});

  @override
  State<SocialSchedulerSheet> createState() => _SocialSchedulerSheetState();
}

enum SchedulerState { idle, loading, success }

class _SocialSchedulerSheetState extends State<SocialSchedulerSheet> {
  late final TextEditingController _facebookController;
  late final TextEditingController _telegramController;
  bool _scheduleForLater = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _facebookSelected = true;
  bool _telegramSelected = true;
  bool _isGenerating = false;
  String? _posterPrompt;
  String? _resultMessage;

  SchedulerState _currentState = SchedulerState.idle;

  final SocialRepository _socialRepository = SocialRepository();

  @override
  void initState() {
    super.initState();
    final dateStr = DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(widget.event.date);
    final fallback = '📢 Upcoming Event: ${widget.event.name}\n'
        '📍 Venue: ${widget.event.venue}\n'
        '📅 Date: $dateStr\n\n'
        '${widget.event.description}\n\n'
        'Join us for this exciting club event! See you there! 🚗💨';
    _facebookController = TextEditingController(text: fallback);
    _telegramController = TextEditingController(text: fallback);
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  void dispose() {
    _facebookController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _generateWithAi() async {
    setState(() => _isGenerating = true);
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final aiService = AIService(apiKey);
      final draft = await aiService.generateSocialPost(
        widget.event.name,
        widget.event.description,
      );
      if (!mounted) return;
      setState(() {
        _facebookController.text = draft.facebookCaption;
        _telegramController.text = draft.telegramMessage;
        _posterPrompt = draft.posterPrompt;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI generation failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
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

  DateTime get _resolvedScheduledTime {
    if (!_scheduleForLater || _selectedDate == null || _selectedTime == null) {
      return DateTime.now();
    }
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
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

    final platforms = [
      if (_facebookSelected) 'facebook',
      if (_telegramSelected) 'telegram',
    ];

    var post = ScheduledPost(
      id: '',
      eventId: widget.event.eventId,
      eventName: widget.event.name,
      targetPlatforms: platforms,
      scheduledTime: _resolvedScheduledTime,
      facebookCaption: _facebookController.text,
      telegramMessage: _telegramController.text,
      posterPrompt: _posterPrompt ?? '',
      createdAt: DateTime.now(),
    );

    try {
      post = await _socialRepository.createPost(post);

      // Telegram is wired to the real Bot API; Facebook has no backend
      // this sprint, so it always stays pending for manual posting.
      if (_telegramSelected && !_scheduleForLater) {
        try {
          final botToken = dotenv.env['TELEGRAM_BOT_TOKEN'] ?? '';
          final chatId = dotenv.env['TELEGRAM_CHAT_ID'] ?? '';
          await TelegramService(botToken).sendMessage(
            chatId: chatId,
            text: _telegramController.text,
          );
          await _socialRepository.updateStatus(post.id, ScheduledPostStatus.posted);
          _resultMessage = _facebookSelected
              ? 'Sent to Telegram now. Facebook caption saved — post it manually.'
              : 'Sent to Telegram now.';
        } catch (e) {
          await _socialRepository.updateStatus(post.id, ScheduledPostStatus.failed);
          _resultMessage =
              'Telegram send failed: ${e.toString().replaceFirst('Exception: ', '')}';
        }
      } else {
        _resultMessage = _scheduleForLater
            ? 'Saved for later. Sending isn\'t automated yet — come back to send Telegram manually at the scheduled time, and post Facebook manually.'
            : 'Saved. Post Facebook manually using the generated caption.';
      }

      if (mounted) {
        setState(() {
          _currentState = SchedulerState.success;
        });
      }

      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_resultMessage ?? 'Post saved.'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentState = SchedulerState.idle;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save post: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // ── AI Generate ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _generateWithAi,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF7C3AED)),
              label: Text(
                _isGenerating ? 'Generating…' : 'Generate with AI',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C3AED),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF7C3AED)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_posterPrompt != null && _posterPrompt!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Flyer prompt: $_posterPrompt',
              style: AppTextStyles.bodySm.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ── Message Boxes ──────────────────────────────────────────────────
          if (_facebookSelected) ...[
            Text('Facebook Caption', style: AppTextStyles.label.copyWith(letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _facebookController,
              maxLines: 4,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'Enter your Facebook announcement here...',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_telegramSelected) ...[
            Text('Telegram Message', style: AppTextStyles.label.copyWith(letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _telegramController,
              maxLines: 4,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'Enter your Telegram message here...',
                hintStyle: const TextStyle(color: AppColors.textDisabled),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
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
                        ? 'Telegram send will need to be triggered manually at this time'
                        : 'Telegram will be sent immediately',
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
            _scheduleForLater ? 'Saving scheduled post...' : 'Publishing announcement...',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          const Text(
            'Saving to Firestore and contacting Telegram',
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
            'Saved',
            style: AppTextStyles.h2.copyWith(color: Colors.green.shade800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _resultMessage ?? '',
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
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
