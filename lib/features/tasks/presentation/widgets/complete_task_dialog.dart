import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/shared_widgets/text_field.dart';
import 'package:flutter/material.dart';

class CompleteTaskDialog extends StatefulWidget {
  final String taskName;
  final void Function(String completionMessage) onConfirm;

  const CompleteTaskDialog({
    super.key,
    required this.taskName,
    required this.onConfirm,
  });

  @override
  State<CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends State<CompleteTaskDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark, width: 1.5),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Complete Task', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                widget.taskName,
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Completion Note',
                hintText: 'Describe what was done...',
                textEditingController: _controller,
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please add a completion note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          widget.onConfirm(_controller.text.trim());
                        }
                      },
                      child: Text(
                        'Confirm',
                        style: AppTextStyles.bodyMdInverted.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
