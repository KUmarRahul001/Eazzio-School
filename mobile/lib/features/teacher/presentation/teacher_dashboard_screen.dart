import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eazzio_school/features/auth/presentation/auth_controller.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import '../data/teacher_repository.dart';
import '../models/teacher_models.dart';
import 'teacher_courses_screen.dart';
import 'teacher_attendance_history_screen.dart';
import 'teacher_notices_screen.dart';
import 'teacher_feedback_screen.dart';
import 'teacher_profile_screen.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeacherRepository(client);
});

final teacherDashboardProvider =
    FutureProvider.autoDispose<TeacherDashboardData>((ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return await repo.getDashboardSummary();
});

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(teacherDashboardProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teacher Portal',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            Text(user?.name ?? 'Faculty',
                style:
                    GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Faculty Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeacherProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(teacherDashboardProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            tooltip: 'Sign Out',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text(
                      'Are you sure you want to sign out of Teacher Portal?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(authNotifierProvider.notifier).logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppTheme.errorRed),
              const SizedBox(height: 12),
              Text('Error loading dashboard: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => ref.refresh(teacherDashboardProvider),
                  child: const Text('Retry')),
            ],
          ),
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(teacherDashboardProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Faculty Profile Card
                Card(
                  color: AppTheme.teacherAccent,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(Icons.co_present_rounded,
                              size: 30, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Teacher',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.hasHomeroom
                                    ? 'Class Teacher: ${data.assignedCourse}'
                                    : 'Subject Faculty',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.9)),
                              ),
                              Text(
                                'Employee ID: ${user?.loginId ?? "EMP"}',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withValues(alpha: 0.75)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Homeroom Class Quick Stats
                if (data.hasHomeroom) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.groups_outlined,
                                        color: AppTheme.teacherAccent,
                                        size: 20),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Students',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppTheme.textMuted),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${data.studentCount ?? 0}',
                                  style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark),
                                ),
                                Text(data.assignedCourse,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pie_chart_outline,
                                        color: AppTheme.successGreen, size: 20),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Class Attendance',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppTheme.textMuted),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${data.courseAttendanceRate ?? 0}%',
                                  style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.successGreen),
                                ),
                                Text('Recent average',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Quick Workspaces & Courseroom Actions (Matching Web Portal)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Courseroom Workspaces',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _QuickActionCard(
                            icon: Icons.groups_rounded,
                            title: 'My Courses',
                            subtitle: 'Rosters & Student Info',
                            color: AppTheme.teacherAccent,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TeacherCoursesScreen()),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _QuickActionCard(
                            icon: Icons.history_rounded,
                            title: 'Attendance Log',
                            subtitle: 'Historical Records',
                            color: const Color(0xFF0284C7),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TeacherAttendanceHistoryScreen()),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _QuickActionCard(
                            icon: Icons.campaign_rounded,
                            title: 'Notice Board',
                            subtitle: 'Circulars & Circulars',
                            color: const Color(0xFFD97706),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TeacherNoticesScreen()),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _QuickActionCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Feedback',
                            subtitle: 'Remarks & Notes',
                            color: const Color(0xFF16A34A),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TeacherFeedbackScreen()),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Today's Routine
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Today's Teaching Schedule",
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE').format(DateTime.now()),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.teacherAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),

                if (data.routine.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text('No classes assigned for today.',
                            style:
                                GoogleFonts.inter(color: AppTheme.textMuted)),
                      ),
                    ),
                  )
                else
                  ...data.routine.map((r) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.teacherAccent.withValues(alpha: 0.12),
                            child: Text(r.period,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.teacherAccent)),
                          ),
                          title: Text(r.subject,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'Class: ${r.courseName ?? "Assigned Class"} ${r.roomNo != null ? "• Room: ${r.roomNo}" : ""}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppTheme.textMuted)),
                          trailing: (r.startTime != null && r.endTime != null)
                              ? Text('${r.startTime} - ${r.endTime}',
                                  style: GoogleFonts.inter(fontSize: 11))
                              : null,
                        ),
                      )),

                const SizedBox(height: 16),

                // Recent Absentees from Class
                if (data.recentAbsentees.isNotEmpty) ...[
                  Text('Recent Absentees (Homeroom)',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...data.recentAbsentees.map((a) => Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person_off_outlined,
                              color: AppTheme.errorRed),
                          title: Text(a.name,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: Text('Roll No: ${a.rollNumber ?? "N/A"}',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppTheme.textMuted)),
                          trailing: Text(a.date.split('T').first,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppTheme.textMuted)),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
