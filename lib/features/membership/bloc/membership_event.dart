import 'package:flutter/foundation.dart';

@immutable
abstract class MembershipEvent {}

class SubmitApplicationEvent extends MembershipEvent {
  final String uid;
  final String userName;
  final String committee;
  final String position;
  final String whyPosition;
  final String experience;

  SubmitApplicationEvent({
    required this.uid,
    required this.userName,
    required this.committee,
    required this.position,
    required this.whyPosition,
    required this.experience,
  });
}
