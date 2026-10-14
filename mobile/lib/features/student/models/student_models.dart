class StudentDashboardData {
  final StudentProfileSummary profile;
  final StudentAttendanceSummary attendance;
  final StudentFeesSummary fees;
  final List<NoticeItem> notices;
  final List<RoutineItem> todayRoutine;

  StudentDashboardData({
    required this.profile,
    required this.attendance,
    required this.fees,
    required this.notices,
    required this.todayRoutine,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      profile: StudentProfileSummary.fromJson(json['profile'] ?? {}),
      attendance: StudentAttendanceSummary.fromJson(json['attendance'] ?? {}),
      fees: StudentFeesSummary.fromJson(json['fees'] ?? {}),
      notices: (json['notices'] as List? ?? [])
          .map((n) => NoticeItem.fromJson(n))
          .toList(),
      todayRoutine: (json['todayRoutine'] as List? ?? [])
          .map((r) => RoutineItem.fromJson(r))
          .toList(),
    );
  }
}

class StudentProfileSummary {
  final String name;
  final String studentId;
  final String rollNumber;
  final String courseName;

  StudentProfileSummary({
    required this.name,
    required this.studentId,
    required this.rollNumber,
    required this.courseName,
  });

  factory StudentProfileSummary.fromJson(Map<String, dynamic> json) {
    return StudentProfileSummary(
      name: json['name'] ?? '',
      studentId: json['studentId'] ?? '',
      rollNumber: json['rollNumber'] ?? 'N/A',
      courseName: json['courseName'] ?? 'Unassigned',
    );
  }
}

class StudentAttendanceSummary {
  final int percentage;
  final int present;
  final int absent;
  final int late;
  final int total;

  StudentAttendanceSummary({
    required this.percentage,
    required this.present,
    required this.absent,
    required this.late,
    required this.total,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      percentage: (json['percentage'] as num?)?.toInt() ?? 100,
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      late: (json['late'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class StudentFeesSummary {
  final double totalFees;
  final double paidAmount;
  final double pendingAmount;
  final String feeStatus;
  final String? dueDate;

  StudentFeesSummary({
    required this.totalFees,
    required this.paidAmount,
    required this.pendingAmount,
    required this.feeStatus,
    this.dueDate,
  });

  factory StudentFeesSummary.fromJson(Map<String, dynamic> json) {
    return StudentFeesSummary(
      totalFees: (json['totalFees'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      feeStatus: json['feeStatus'] ?? 'PAID',
      dueDate: json['dueDate'],
    );
  }
}

class StudentFullProfile {
  final int id;
  final String studentId;
  final String name;
  final String? fatherName;
  final String? motherName;
  final String? phone;
  final String? address;
  final String? rollNumber;
  final String? admissionDate;
  final String? feeCycle;
  final CourseInfo? course;

  StudentFullProfile({
    required this.id,
    required this.studentId,
    required this.name,
    this.fatherName,
    this.motherName,
    this.phone,
    this.address,
    this.rollNumber,
    this.admissionDate,
    this.feeCycle,
    this.course,
  });

  factory StudentFullProfile.fromJson(Map<String, dynamic> json) {
    return StudentFullProfile(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      phone: json['phone'],
      address: json['address'],
      rollNumber: json['rollNumber'],
      admissionDate: json['admissionDate'],
      feeCycle: json['feeCycle'],
      course:
          json['course'] != null ? CourseInfo.fromJson(json['course']) : null,
    );
  }
}

class CourseInfo {
  final int id;
  final String courseName;
  final String section;
  final String academicYear;
  final String? classTeacherName;

  CourseInfo({
    required this.id,
    required this.courseName,
    required this.section,
    required this.academicYear,
    this.classTeacherName,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      courseName: json['courseName'] ?? '',
      section: json['section'] ?? '',
      academicYear: json['academicYear'] ?? '',
      classTeacherName:
          json['teacher'] != null ? json['teacher']['name'] : null,
    );
  }
}

class AttendanceRecord {
  final int id;
  final String date;
  final String status;
  final String? teacherName;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.status,
    this.teacherName,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? 'PRESENT',
      teacherName: json['teacher'] != null ? json['teacher']['name'] : null,
    );
  }
}

class RoutineItem {
  final int id;
  final String period;
  final String subject;
  final String dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? roomNo;
  final String? teacherName;

  RoutineItem({
    required this.id,
    required this.period,
    required this.subject,
    required this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.roomNo,
    this.teacherName,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      period: json['period']?.toString() ?? '1',
      subject: json['subject'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      roomNo: json['roomNo'],
      teacherName: json['teacher'] != null ? json['teacher']['name'] : null,
    );
  }
}

class NoticeItem {
  final int id;
  final String title;
  final String content;
  final String? attachmentUrl;
  final String? date;
  final String audience;

  NoticeItem({
    required this.id,
    required this.title,
    required this.content,
    this.attachmentUrl,
    this.date,
    required this.audience,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      date: json['date'] ?? json['createdAt'],
      audience: json['audience'] ?? 'SCHOOL',
    );
  }
}

class FeeInvoiceItem {
  final int id;
  final String invoiceNumber;
  final String feeType;
  final double amount;
  final String dueDate;
  final String status;
  final List<FeePaymentRecord> payments;

  FeeInvoiceItem({
    required this.id,
    required this.invoiceNumber,
    required this.feeType,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.payments,
  });

  factory FeeInvoiceItem.fromJson(Map<String, dynamic> json) {
    return FeeInvoiceItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      invoiceNumber: json['invoiceNumber'] ?? 'INV-${json['id']}',
      feeType: json['feeType'] ?? 'Tuition Fee',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] ?? '',
      status: json['status'] ?? 'PENDING',
      payments: (json['payments'] as List? ?? [])
          .map((p) => FeePaymentRecord.fromJson(p))
          .toList(),
    );
  }

  double get paidAmount => payments.fold(0.0, (acc, p) => acc + p.amount);
  double get pendingAmount => (amount - paidAmount).clamp(0.0, double.infinity);
}

class FeePaymentRecord {
  final int id;
  final double amount;
  final String date;
  final String status;
  final String? paymentMethod;
  final String? receiptNumber;

  FeePaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    this.paymentMethod,
    this.receiptNumber,
  });

  factory FeePaymentRecord.fromJson(Map<String, dynamic> json) {
    return FeePaymentRecord(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? json['createdAt'] ?? '',
      status: json['status'] ?? 'SUCCESS',
      paymentMethod: json['paymentMethod'],
      receiptNumber: json['receiptNumber'],
    );
  }
}

class AssignmentItem {
  final int id;
  final String title;
  final String description;
  final String? dueDate;
  final String? attachmentUrl;
  final String? teacherName;
  final String? courseName;
  final String createdAt;

  AssignmentItem({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.attachmentUrl,
    this.teacherName,
    this.courseName,
    required this.createdAt,
  });

  factory AssignmentItem.fromJson(Map<String, dynamic> json) {
    return AssignmentItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'],
      attachmentUrl: json['attachmentUrl'],
      teacherName: json['teacher'] != null ? json['teacher']['name'] : null,
      courseName: json['course'] != null
          ? '${json['course']['courseName']}-${json['course']['section']}'
          : null,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class StudentResultGroup {
  final bool resultOnHold;
  final String? holdMessage;
  final List<dynamic> weeklyTests;
  final List<dynamic> terminalExams;
  final List<dynamic> generalExams;

  StudentResultGroup({
    required this.resultOnHold,
    this.holdMessage,
    required this.weeklyTests,
    required this.terminalExams,
    required this.generalExams,
  });

  factory StudentResultGroup.fromJson(Map<String, dynamic> json) {
    return StudentResultGroup(
      resultOnHold: json['resultOnHold'] == true,
      holdMessage: json['message'],
      weeklyTests: json['weeklyTests'] as List? ?? [],
      terminalExams: json['terminalExams'] as List? ?? [],
      generalExams: json['exams'] as List? ?? [],
    );
  }
}

class ExamTimetableItem {
  final int id;
  final String title;
  final String examType;
  final String academicYear;
  final bool published;
  final String? courseName;
  final List<ExamTimetableSlot> items;

  ExamTimetableItem({
    required this.id,
    required this.title,
    required this.examType,
    required this.academicYear,
    required this.published,
    this.courseName,
    required this.items,
  });

  factory ExamTimetableItem.fromJson(Map<String, dynamic> json) {
    String? courseStr;
    if (json['course'] != null) {
      courseStr =
          '${json['course']['courseName']}-${json['course']['section']}';
    }
    return ExamTimetableItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      examType: json['examType'] ?? 'EXAM',
      academicYear: json['academicYear'] ?? '',
      published: json['published'] == true,
      courseName: courseStr,
      items: (json['items'] as List? ?? [])
          .map((i) => ExamTimetableSlot.fromJson(i))
          .toList(),
    );
  }
}

class ExamTimetableSlot {
  final int id;
  final String subject;
  final String examDate;
  final String startTime;
  final String endTime;
  final double? maxMarks;
  final String? roomNo;

  ExamTimetableSlot({
    required this.id,
    required this.subject,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    this.maxMarks,
    this.roomNo,
  });

  factory ExamTimetableSlot.fromJson(Map<String, dynamic> json) {
    return ExamTimetableSlot(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      subject: json['subject'] ?? '',
      examDate: json['examDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      maxMarks: (json['maxMarks'] as num?)?.toDouble(),
      roomNo: json['roomNo'],
    );
  }
}
