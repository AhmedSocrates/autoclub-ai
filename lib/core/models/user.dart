// Equatable used for equality checking for BLoC state management
import 'package:equatable/equatable.dart';

class UserModel extends Equatable{

  final String userId;
  final String name;
  final String role;
  final bool isMember;
  final bool isAvailable;
  final String? fcmToken;

  const UserModel({
    required this.userId,
    required this.name,
    required this.role,
    this.isMember = false,
    this.isAvailable = true,
    this.fcmToken,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isMember: (json['is_member'] as bool?) ?? false,
      isAvailable: (json['is_available'] as bool?) ?? true,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'role': role,
      'is_member': isMember,
      'is_available': isAvailable,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }

  @override

  List<Object?> get props => [userId, name, role, isMember, isAvailable, fcmToken];
}
