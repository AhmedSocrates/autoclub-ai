// lib/features/membership/bloc/membership_event.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class MembershipEvent {}

class SubmitApplicationEvent extends MembershipEvent {
  final String name;
  final String studentId;
  final String reason;

  SubmitApplicationEvent({
    required this.name,
    required this.studentId,
    required this.reason,
  });
}