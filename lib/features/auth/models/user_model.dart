import 'package:equatable/equatable.dart';

/// User model matching Supabase 'users' table
class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role; // 'admin' | 'user' | 'hr' | 'it'
  final String? department;
  final String? jobTitle;
  final String? phone;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.role = 'user',
    this.department,
    this.jobTitle,
    this.phone,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isHR => role == 'hr' || isAdmin;
  bool get isIT => role == 'it' || isAdmin;
  bool get hasAdminAccess => isAdmin || isHR || isIT;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      department: json['department'] as String?,
      jobTitle: json['job_title'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'department': department,
      'job_title': jobTitle,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? role,
    String? department,
    String? jobTitle,
    String? phone,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        role,
        department,
        jobTitle,
        phone,
        createdAt
      ];
}
