import 'package:flutter/material.dart';
import 'package:employee_portal/core/theme/app_colors.dart';

/// Represents a single real-time in-app notification popup
class NotificationOverlayModel {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final String? navigateTo; // route to push when tapped

  const NotificationOverlayModel({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.gradient,
    this.navigateTo,
  });

  factory NotificationOverlayModel.news({
    required String id,
    required String title,
  }) =>
      NotificationOverlayModel(
        id: id,
        title: 'خبر جديد 📰',
        body: title,
        icon: Icons.newspaper_rounded,
        color: AppColors.newsColor,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        navigateTo: '/news/$id',
      );

  factory NotificationOverlayModel.event({
    required String id,
    required String title,
  }) =>
      NotificationOverlayModel(
        id: id,
        title: 'فعالية جديدة 🎉',
        body: title,
        icon: Icons.event_rounded,
        color: AppColors.eventsColor,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        navigateTo: '/events/$id',
      );

  factory NotificationOverlayModel.hr({
    required String id,
    required String title,
  }) =>
      NotificationOverlayModel(
        id: id,
        title: 'تحديث الموارد البشرية 👥',
        body: title,
        icon: Icons.people_rounded,
        color: AppColors.hrColor,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        navigateTo: '/hr',
      );

  factory NotificationOverlayModel.it({
    required String id,
    required String title,
  }) =>
      NotificationOverlayModel(
        id: id,
        title: 'تحديث تقنية المعلومات 💻',
        body: title,
        icon: Icons.computer_rounded,
        color: AppColors.itColor,
        gradient: const LinearGradient(
          colors: [Color(0xFF0ABFBC), Color(0xFF1E6BE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        navigateTo: '/it',
      );
}
