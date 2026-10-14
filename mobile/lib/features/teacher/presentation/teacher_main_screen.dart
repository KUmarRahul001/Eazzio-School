import 'package:flutter/material.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import 'package:eazzio_school/core/theme/app_icons.dart';
import 'teacher_dashboard_screen.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_assignments_screen.dart';
import 'teacher_routine_screen.dart';
import 'teacher_marks_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TeacherDashboardScreen(),
    TeacherAttendanceScreen(),
    TeacherAssignmentsScreen(),
    TeacherRoutineScreen(),
    TeacherMarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 64,
        indicatorColor: AppTheme.teacherAccent.withValues(alpha: 0.15),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: AppIcons.render(AppIcons.teacherPortal, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.teacherAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.teacherPortal, size: 22),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.attendance, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.teacherAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.attendance, size: 22),
            ),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.assignments, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.teacherAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.assignments, size: 22),
            ),
            label: 'Homework',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.routine, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.teacherAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.routine, size: 22),
            ),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.marks, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.teacherAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.marks, size: 22),
            ),
            label: 'Marks',
          ),
        ],
      ),
    );
  }
}
