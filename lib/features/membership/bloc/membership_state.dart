// lib/features/membership/bloc/membership_state.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class MembershipState {}

class MembershipInitial extends MembershipState {}

class MembershipLoading extends MembershipState {}

class MembershipSuccess extends MembershipState {
  final String message;
  MembershipSuccess(this.message);
}

class MembershipError extends MembershipState {
  final String errorMessage;
  MembershipError(this.errorMessage);
}