
import 'package:auto_club_ai/core/models/user.dart';
import 'package:flutter/material.dart';

@immutable
abstract class UserEvent {}

class ChangeUserName extends UserEvent {
  final UserModel user;
  final String name;

  ChangeUserName(this.name, this.user);

  List<Object?> get props => [user, name];
}
class ViewInputField extends UserEvent {}
class DismissAlert extends UserEvent {}

class ChangePasswordRequested extends UserEvent {}
