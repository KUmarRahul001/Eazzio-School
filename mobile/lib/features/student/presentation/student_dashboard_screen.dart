import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eazzio_school/features/auth/presentation/auth_controller.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import 'package:eazzio_school/core/theme/app_icons.dart';
import 'package:eazzio_school/core/config/app_config.dart';
import '../data/student_repository.dart';
import '../models/student_models.dart';
import 'package:eazzio_school/features/shared/presentation/pdf_viewer_screen.dart';
import 'student_notices_screen.dart';
import 'student_class_details_screen.dart';
import 'student_results_screen.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return StudentRepository(client);
});

final studentDashboardProvider =
    FutureProvider.autoDispose<StudentDashboardData>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getDashboardSummary();
});

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(studentDashboardProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Portal',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            Text(user?.name ?? 'Student',
                style:
                    GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(studentDashboardProvider),
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
                      'Are you sure you want to sign out of Student Portal?'),
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
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppTheme.errorRed),
                const SizedBox(height: 12),
                Text('Could not load dashboard data',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 6),
                Text(err.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(studentDashboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final profile = data.profile;
          final att = data.attendance;
          final fees = data.fees;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(studentDashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting & Profile Card
                  Card(
                    color: AppTheme.studentAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.school,
                                size: 32, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Class: ${profile.courseName} | Roll: ${profile.rollNumber}',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color:
                                          Colors.white.withValues(alpha: 0.9)),
                                ),
                                Text(
                                  'ID: ${profile.studentId}',
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

                  // Quick Stats Grid: Attendance & Fees
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isVeryNarrow = constraints.maxWidth < 280;
                      final attendanceCard = Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_available,
                                      color: AppTheme.studentAccent,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text('Attendance',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: AppTheme.textMuted)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${att.percentage}%',
                                  style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Present: ${att.present} / ${att.total} days',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      );

                      final feeCard = Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: fees.pendingAmount > 0
                                        ? AppTheme.errorRed
                                        : AppTheme.successGreen,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text('Fee Status',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: AppTheme.textMuted)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '₹${fees.pendingAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: fees.pendingAmount > 0
                                        ? AppTheme.errorRed
                                        : AppTheme.successGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fees.pendingAmount > 0
                                    ? 'Pending Dues'
                                    : 'All Clear',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: fees.pendingAmount > 0
                                      ? AppTheme.errorRed
                                      : AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (isVeryNarrow) {
                        return Column(
                          children: [
                            attendanceCard,
                            const SizedBox(height: 8),
                            feeCard,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: attendanceCard),
                          const SizedBox(width: 8),
                          Expanded(child: feeCard),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Student Workspaces & Actions (Matching Web Portal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student Workspaces',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: _StudentWorkspaceCard(
                              customAsset: AppIcons.courses,
                              title: 'Class Details',
                              subtitle: 'Faculty & Routine',
                              color: AppTheme.studentAccent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentClassDetailsScreen()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: _StudentWorkspaceCard(
                              customAsset: AppIcons.notices,
                              title: 'Notice Board',
                              subtitle: 'Circulars & Notes',
                              color: const Color(0xFFD97706),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentNoticesScreen()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: _StudentWorkspaceCard(
                              customAsset: AppIcons.routine,
                              title: 'Exam Schedule',
                              subtitle: 'Published Datesheets',
                              color: const Color(0xFF0284C7),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentResultsScreen()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: _StudentWorkspaceCard(
                              customAsset: AppIcons.results,
                              title: 'Report Cards',
                              subtitle: 'Grades & Results',
                              color: const Color(0xFF16A34A),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentResultsScreen()),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Today's Timetable Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Today's Schedule",
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE').format(DateTime.now()),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.studentAccent,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (data.todayRoutine.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.event_busy_outlined,
                                  size: 36, color: AppTheme.textMuted),
                              const SizedBox(height: 8),
                              Text('No classes scheduled for today',
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...data.todayRoutine.map((r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.studentAccent
                                  .withValues(alpha: 0.12),
                              child: Text(r.period,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.studentAccent)),
                            ),
                            title: Text(r.subject,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              'Teacher: ${r.teacherName ?? "Faculty"} ${r.roomNo != null ? "• Room: ${r.roomNo}" : ""}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppTheme.textMuted),
                            ),
                            trailing: (r.startTime != null && r.endTime != null)
                                ? Text('${r.startTime} - ${r.endTime}',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500))
                                : null,
                          ),
                        )),

                  const SizedBox(height: 20),

                  // Recent Notices Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent School Notices',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentNoticesScreen()),
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.studentAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (data.notices.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text('No recent notices',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textMuted, fontSize: 13)),
                        ),
                      ),
                    )
                  else
                    ...data.notices.map((n) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.campaign_outlined,
                                color: AppTheme.studentAccent),
                            title: Text(n.title,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 12)),
                                if (n.attachmentUrl != null) ...[
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      final fullUrl =
                                          '${AppConfig.uploadsBaseUrl}${n.attachmentUrl}';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfViewerScreen(
                                              title: n.title, pdfUrl: fullUrl),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.picture_as_pdf,
                                            size: 14, color: AppTheme.errorRed),
                                        const SizedBox(width: 4),
                                        Text('View Attachment (PDF)',
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: AppTheme.primaryBlue,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StudentWorkspaceCard extends StatelessWidget {
  final String customAsset;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StudentWorkspaceCard({
    required this.customAsset,
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
              AppIcons.render(customAsset, size: 36),
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
