import 'package:flutter/material.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import 'package:eazzio_school/core/theme/app_icons.dart';
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
        destinations: [
          NavigationDestination(
            icon: AppIcons.render(AppIcons.studentPortal, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.studentPortal, size: 22),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.attendance, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.attendance, size: 22),
            ),
            label: 'Roll',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.routine, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.routine, size: 22),
            ),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.assignments, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.assignments, size: 22),
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.fees, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.fees, size: 22),
            ),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.results, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.results, size: 22),
            ),
            label: 'Results',
          ),
          NavigationDestination(
            icon: AppIcons.render(AppIcons.profile, size: 22),
            selectedIcon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.studentAccent.withValues(alpha: 0.2),
              ),
              child: AppIcons.render(AppIcons.profile, size: 22),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
