import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import '../models/teacher_models.dart';
import 'teacher_dashboard_screen.dart';

final teacherRoutineProvider =
    FutureProvider.autoDispose<Map<String, List<TeacherRoutineItem>>>(
        (ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return await repo.getRoutine();
});

class TeacherRoutineScreen extends ConsumerWidget {
  const TeacherRoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineAsync = ref.watch(teacherRoutineProvider);
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faculty Routine'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.teacherAccent,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.teacherAccent,
            tabs: days.map((d) => Tab(text: d)).toList(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.refresh(teacherRoutineProvider),
            ),
          ],
        ),
        body: routineAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading routine: $err')),
          data: (routineMap) {
            return TabBarView(
              children: days.map((day) {
                final periods = routineMap[day] ?? [];
                if (periods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.free_breakfast_outlined,
                            size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text('No periods scheduled on $day',
                            style:
                                GoogleFonts.inter(color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: periods.length,
                  itemBuilder: (ctx, i) {
                    final item = periods[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.teacherAccent.withValues(alpha: 0.12),
                          child: Text(item.period,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.teacherAccent)),
                        ),
                        title: Text(item.subject,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text(
                          'Class: ${item.courseName ?? "Assigned Course"} ${item.roomNo != null ? "• Room: ${item.roomNo}" : ""}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                        trailing:
                            (item.startTime != null && item.endTime != null)
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                        '${item.startTime} - ${item.endTime}',
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500)),
                                  )
                                : null,
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
