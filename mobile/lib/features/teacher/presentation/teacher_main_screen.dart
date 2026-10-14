import 'package:flutter/material.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
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
        indicatorColor: AppTheme.teacherAccent.withValues(alpha: 0.15),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.teacherAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg, color: AppTheme.teacherAccent),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppTheme.teacherAccent),
            label: 'Homework',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule, color: AppTheme.teacherAccent),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined),
            selectedIcon: Icon(Icons.grade, color: AppTheme.teacherAccent),
            label: 'Marks',
          ),
        ],
      ),
    );
  }
}
