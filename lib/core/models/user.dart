// Equatable used for equality checking for BLoC state management
import 'package:equatable/equatable.dart';

class UserModel extends Equatable{

  final String userId;
  final String name;
  final String role;
  final bool isMember;
  final bool isAvailable;

  const UserModel({
    required this.userId,
    required this.name,
    required this.role,
    this.isMember = false,
    this.isAvailable = true,
  });

  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isMember: (json['is_member'] as bool?) ?? false,
      isAvailable: (json['is_available'] as bool?) ?? true,
    );
  }

  // for storage
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'role': role,
      'is_member': isMember,
      'is_available': isAvailable,
    };
  }
  
  @override

  List<Object?> get props => [userId, name, role, isMember, isAvailable];
}
