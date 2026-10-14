class TeacherDashboardData {
  final bool hasHomeroom;
  final String assignedCourse;
  final int? studentCount;
  final int? courseAttendanceRate;
  final List<AbsenteeItem> recentAbsentees;
  final List<TeacherRoutineItem> routine;

  TeacherDashboardData({
    required this.hasHomeroom,
    required this.assignedCourse,
    this.studentCount,
    this.courseAttendanceRate,
    required this.recentAbsentees,
    required this.routine,
  });

  factory TeacherDashboardData.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardData(
      hasHomeroom: json['hasHomeroom'] == true,
      assignedCourse: json['assignedCourse'] ?? 'Unassigned',
      studentCount: (json['studentCount'] as num?)?.toInt(),
      courseAttendanceRate: (json['courseAttendanceRate'] as num?)?.toInt(),
      recentAbsentees: (json['recentAbsentees'] as List? ?? [])
          .map((a) => AbsenteeItem.fromJson(a))
          .toList(),
      routine: (json['routine'] as List? ?? [])
          .map((r) => TeacherRoutineItem.fromJson(r))
          .toList(),
    );
  }
}

class AbsenteeItem {
  final int studentId;
  final String name;
  final String? rollNumber;
  final String date;

  AbsenteeItem({
    required this.studentId,
    required this.name,
    this.rollNumber,
    required this.date,
  });

  factory AbsenteeItem.fromJson(Map<String, dynamic> json) {
    return AbsenteeItem(
      studentId: json['studentId'] is int
          ? json['studentId']
          : int.tryParse(json['studentId'].toString()) ?? 0,
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'],
      date: json['date'] ?? '',
    );
  }
}

class TeacherRoutineItem {
  final int id;
  final String period;
  final String subject;
  final String dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? roomNo;
  final String? courseName;

  TeacherRoutineItem({
    required this.id,
    required this.period,
    required this.subject,
    required this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.roomNo,
    this.courseName,
  });

  factory TeacherRoutineItem.fromJson(Map<String, dynamic> json) {
    String? courseStr;
    if (json['course'] != null) {
      courseStr =
          '${json['course']['courseName']}-${json['course']['section']}';
    }
    return TeacherRoutineItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      period: json['period']?.toString() ?? '1',
      subject: json['subject'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      roomNo: json['roomNo'],
      courseName: courseStr,
    );
  }
}

class TeacherClassItem {
  final int courseId;
  final String courseName;
  final String section;
  final bool isHomeroom;
  final List<String> subjects;
  final List<RosterStudent> students;

  TeacherClassItem({
    required this.courseId,
    required this.courseName,
    required this.section,
    required this.isHomeroom,
    required this.subjects,
    required this.students,
  });

  factory TeacherClassItem.fromJson(Map<String, dynamic> json) {
    return TeacherClassItem(
      courseId: json['courseId'] is int
          ? json['courseId']
          : int.tryParse(json['courseId'].toString()) ?? 0,
      courseName: json['courseName'] ?? '',
      section: json['section'] ?? '',
      isHomeroom: json['isHomeroom'] == true,
      subjects:
          (json['subjects'] as List? ?? []).map((s) => s.toString()).toList(),
      students: (json['students'] as List? ?? [])
          .map((s) => RosterStudent.fromJson(s))
          .toList(),
    );
  }

  String get displayName => '$courseName-$section';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherClassItem &&
          runtimeType == other.runtimeType &&
          courseId == other.courseId;

  @override
  int get hashCode => courseId.hashCode;
}

class RosterStudent {
  final int id;
  final String studentId;
  final String name;
  final String? rollNumber;
  final String? phone;

  RosterStudent({
    required this.id,
    required this.studentId,
    required this.name,
    this.rollNumber,
    this.phone,
  });

  factory RosterStudent.fromJson(Map<String, dynamic> json) {
    return RosterStudent(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? 'N/A',
      phone: json['phone'],
    );
  }
}

class TeacherAssignmentItem {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final String? courseName;
  final String? dueDate;
  final String? attachmentUrl;
  final String createdAt;

  TeacherAssignmentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.courseName,
    this.dueDate,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory TeacherAssignmentItem.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: (json['courseId'] as num?)?.toInt() ?? 0,
      courseName: json['course'] != null
          ? '${json['course']['courseName']}-${json['course']['section']}'
          : null,
      dueDate: json['dueDate'],
      attachmentUrl: json['attachmentUrl'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class TeacherExamItem {
  final int id;
  final String examName;
  final String term;
  final String academicYear;
  final String? examType;
  final String? subject;
  final double? maxMarks;
  final String? examDate;
  final int courseId;
  final String? courseName;

  TeacherExamItem({
    required this.id,
    required this.examName,
    required this.term,
    required this.academicYear,
    this.examType,
    this.subject,
    this.maxMarks,
    this.examDate,
    required this.courseId,
    this.courseName,
  });

  factory TeacherExamItem.fromJson(Map<String, dynamic> json) {
    return TeacherExamItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      examName: json['examName'] ?? '',
      term: json['term'] ?? '',
      academicYear: json['academicYear'] ?? '',
      examType: json['examType'],
      subject: json['subject'],
      maxMarks: (json['maxMarks'] as num?)?.toDouble(),
      examDate: json['examDate'],
      courseId: json['courseId'] is int
          ? json['courseId']
          : int.tryParse(json['courseId'].toString()) ?? 0,
      courseName: json['course'] != null
          ? '${json['course']['courseName']}-${json['course']['section']}'
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherExamItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MarksSheetStudentRow {
  final int studentId;
  final String name;
  final String rollNumber;
  double? marksObtained;
  String? grade;
  String? remarks;

  MarksSheetStudentRow({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    this.marksObtained,
    this.grade,
    this.remarks,
  });

  factory MarksSheetStudentRow.fromJson(Map<String, dynamic> json) {
    return MarksSheetStudentRow(
      studentId: json['studentId'] is int
          ? json['studentId']
          : int.tryParse(json['studentId'].toString()) ?? 0,
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? 'N/A',
      marksObtained: (json['marksObtained'] as num?)?.toDouble(),
      grade: json['grade'],
      remarks: json['remarks'],
    );
  }
}
