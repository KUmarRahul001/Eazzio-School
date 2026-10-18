import 'package:flutter/material.dart';

/// Central registry of bespoke high-resolution vector-rendered icons for Eazzio-School
class AppIcons {
  static const String studentPortal = 'assets/icons/icon_student_portal.png';
  static const String teacherPortal = 'assets/icons/icon_teacher_portal.png';
  static const String attendance = 'assets/icons/icon_attendance.png';
  static const String routine = 'assets/icons/icon_routine.png';
  static const String assignments = 'assets/icons/icon_assignments.png';
  static const String fees = 'assets/icons/icon_fees.png';
  static const String results = 'assets/icons/icon_results.png';
  static const String notices = 'assets/icons/icon_notices.png';
  static const String profile = 'assets/icons/icon_profile.png';
  static const String courses = 'assets/icons/icon_courses.png';
  static const String feedback = 'assets/icons/icon_feedback.png';
  static const String marks = 'assets/icons/icon_marks.png';

  static IconData _fallbackIcon(String path) {
    if (path.contains('student')) return Icons.school_outlined;
    if (path.contains('teacher')) return Icons.co_present_outlined;
    if (path.contains('attendance')) return Icons.fact_check_outlined;
    if (path.contains('routine')) return Icons.calendar_today_outlined;
    if (path.contains('assignments')) return Icons.assignment_outlined;
    if (path.contains('fees')) return Icons.account_balance_wallet_outlined;
    if (path.contains('results')) return Icons.emoji_events_outlined;
    if (path.contains('notices')) return Icons.campaign_outlined;
    if (path.contains('profile')) return Icons.person_outline;
    if (path.contains('courses')) return Icons.menu_book_outlined;
    if (path.contains('feedback')) return Icons.rate_review_outlined;
    if (path.contains('marks')) return Icons.grade_outlined;
    return Icons.widgets_outlined;
  }

  /// Renders a custom styled app icon with optional dimensions and tinting
  static Widget render(
    String assetPath, {
    double size = 24,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      color: color,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _fallbackIcon(assetPath),
          size: size,
          color: color ?? const Color(0xFF0F766E),
        );
      },
    );
  }
}
