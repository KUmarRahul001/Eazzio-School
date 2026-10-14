import 'package:flutter/material.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import 'student_dashboard_screen.dart';
import 'student_attendance_screen.dart';
import 'student_routine_screen.dart';
import 'student_assignments_screen.dart';
import 'student_fees_screen.dart';
import 'student_results_screen.dart';
import 'student_profile_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudentDashboardScreen(),
    StudentAttendanceScreen(),
    StudentRoutineScreen(),
    StudentAssignmentsScreen(),
    StudentFeesScreen(),
    StudentResultsScreen(),
    StudentProfileScreen(),
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
        indicatorColor: AppTheme.studentAccent.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            selectedIcon:
                Icon(Icons.dashboard, color: AppTheme.studentAccent, size: 20),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined, size: 20),
            selectedIcon: Icon(Icons.calendar_today,
                color: AppTheme.studentAccent, size: 20),
            label: 'Roll',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined, size: 20),
            selectedIcon:
                Icon(Icons.schedule, color: AppTheme.studentAccent, size: 20),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, size: 20),
            selectedIcon:
                Icon(Icons.assignment, color: AppTheme.studentAccent, size: 20),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, size: 20),
            selectedIcon: Icon(Icons.receipt_long,
                color: AppTheme.studentAccent, size: 20),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined, size: 20),
            selectedIcon:
                Icon(Icons.grade, color: AppTheme.studentAccent, size: 20),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 20),
            selectedIcon:
                Icon(Icons.person, color: AppTheme.studentAccent, size: 20),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
