import 'package:flutter/material.dart';

@immutable
abstract class UserState {}

class UsernameInitial extends UserState {}
class UsernameChangeRequested extends UserState {}
class UsernameChangeInputRequested extends UserState {}
class UsernameLoading extends UserState {}
class ShowAlert extends UserState {
  final String message;

  ShowAlert(this.message);

  List<Object?> get props => [message];
}
