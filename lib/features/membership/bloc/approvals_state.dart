// lib/features/membership/presentation/bloc/approvals_state.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class ApprovalsState {}

class ApprovalsInitial extends ApprovalsState {}

class ApprovalsLoading extends ApprovalsState {}

class ApprovalsLoaded extends ApprovalsState {
  
  final List<Map<String, dynamic>> pendingApplications;
  
  ApprovalsLoaded(this.pendingApplications);
}

class ApprovalsError extends ApprovalsState {
  final String message;
  ApprovalsError(this.message);
}