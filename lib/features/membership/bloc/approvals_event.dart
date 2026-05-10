// lib/features/membership/presentation/bloc/approvals_event.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class ApprovalsEvent {}

// Fired as soon as the screen opens to get the data
class FetchPendingApplications extends ApprovalsEvent {}

// Fired when the President clicks Accept or Reject
class DecideApplicationEvent extends ApprovalsEvent {
  final String studentId;
  final bool isApproved;

  DecideApplicationEvent({
    required this.studentId,
    required this.isApproved,
  });
}