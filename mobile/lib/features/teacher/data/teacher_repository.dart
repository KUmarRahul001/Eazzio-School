import '../../../core/network/api_client.dart';
import '../models/teacher_models.dart';

class TeacherRepository {
  final ApiClient _apiClient;

  TeacherRepository(this._apiClient);

  Future<TeacherDashboardData> getDashboardSummary() async {
    final res = await _apiClient.dio.get('/teacher/dashboard-summary');
    if (res.data['success'] == true && res.data['data'] != null) {
      return TeacherDashboardData.fromJson(res.data['data']);
    }
    throw Exception(
        res.data['error'] ?? 'Failed to load teacher dashboard summary');
  }

  Future<List<TeacherClassItem>> getMyClasses() async {
    final res = await _apiClient.dio.get('/teacher/my-classes');
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data'] as List;
      return list.map((c) => TeacherClassItem.fromJson(c)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load teacher classes');
  }

  Future<Map<String, dynamic>> getClassDetails() async {
    final res = await _apiClient.dio.get('/teacher/class-details');
    if (res.data['success'] == true && res.data['data'] != null) {
      return res.data['data'];
    }
    throw Exception(res.data['error'] ?? 'Failed to load class details');
  }

  Future<void> submitAttendance({
    required int courseId,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final res = await _apiClient.dio.post('/teacher/attendance', data: {
      'courseId': courseId,
      'date': date,
      'records': records,
    });
    if (res.data['success'] != true) {
      throw Exception(res.data['error'] ?? 'Failed to record attendance');
    }
  }

  Future<List<String>> getAttendanceHistoryDates({int? courseId}) async {
    final res = await _apiClient.dio.get(
      '/teacher/attendance-history',
      queryParameters: courseId != null ? {'courseId': courseId} : null,
    );
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data']['dates'] as List? ?? [];
      return list.map((d) => d.toString()).toList();
    }
    throw Exception(
        res.data['error'] ?? 'Failed to fetch attendance history dates');
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistoryRecords({
    required String date,
    int? courseId,
  }) async {
    final queryParams = {'date': date};
    if (courseId != null) queryParams['courseId'] = courseId.toString();

    final res = await _apiClient.dio
        .get('/teacher/attendance-history', queryParameters: queryParams);
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data']['records'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception(res.data['error'] ?? 'Failed to fetch attendance history');
  }

  Future<Map<String, List<TeacherRoutineItem>>> getRoutine() async {
    final res = await _apiClient.dio.get('/teacher/routine');
    if (res.data['success'] == true && res.data['data'] != null) {
      final Map<String, dynamic> rawMap = res.data['data'];
      final Map<String, List<TeacherRoutineItem>> result = {};
      rawMap.forEach((day, items) {
        if (items is List) {
          result[day] =
              items.map((i) => TeacherRoutineItem.fromJson(i)).toList();
        }
      });
      return result;
    }
    throw Exception(res.data['error'] ?? 'Failed to load teacher routine');
  }

  Future<List<TeacherAssignmentItem>> getAssignments({int? courseId}) async {
    final queryParams = <String, dynamic>{};
    if (courseId != null) queryParams['courseId'] = courseId;

    final res = await _apiClient.dio
        .get('/teacher/assignments', queryParameters: queryParams);
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data'] as List;
      return list.map((a) => TeacherAssignmentItem.fromJson(a)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load assignments');
  }

  Future<TeacherAssignmentItem> createAssignment({
    required String title,
    required String description,
    required int courseId,
    String? dueDate,
    String? attachmentUrl,
  }) async {
    final res = await _apiClient.dio.post('/teacher/assignments', data: {
      'title': title,
      'description': description,
      'courseId': courseId,
      'dueDate': dueDate,
      'attachmentUrl': attachmentUrl,
    });
    if (res.data['success'] == true && res.data['data'] != null) {
      return TeacherAssignmentItem.fromJson(res.data['data']);
    }
    throw Exception(res.data['error'] ?? 'Failed to create assignment');
  }

  Future<void> deleteAssignment(int id) async {
    final res = await _apiClient.dio.delete('/teacher/assignments/$id');
    if (res.data['success'] != true) {
      throw Exception(res.data['error'] ?? 'Failed to delete assignment');
    }
  }

  // Exams & Marks for Teacher
  Future<List<TeacherExamItem>> getExams({int? courseId}) async {
    final queryParams = <String, dynamic>{};
    if (courseId != null) queryParams['courseId'] = courseId;

    final res =
        await _apiClient.dio.get('/exams/list', queryParameters: queryParams);
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data'] as List;
      return list.map((e) => TeacherExamItem.fromJson(e)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load exams');
  }

  Future<TeacherExamItem> createExam({
    required int courseId,
    required String examName,
    required String term,
    required String academicYear,
    String? examDate,
    String? subject,
    double? maxMarks,
    String examType = 'GENERAL',
    String? portion,
  }) async {
    final res = await _apiClient.dio.post('/exams/create', data: {
      'courseId': courseId,
      'examName': examName,
      'term': term,
      'academicYear': academicYear,
      if (examDate != null) 'examDate': examDate,
      if (subject != null) 'subject': subject,
      if (maxMarks != null) 'maxMarks': maxMarks,
      'examType': examType,
      if (portion != null) 'portion': portion,
    });
    if (res.data['success'] == true && res.data['data'] != null) {
      return TeacherExamItem.fromJson(res.data['data']);
    }
    throw Exception(res.data['error'] ?? 'Failed to create exam');
  }

  Future<Map<String, dynamic>> getMarksSheet({
    required int courseId,
    required int examId,
    required String subject,
  }) async {
    final res =
        await _apiClient.dio.get('/exams/marks-sheet', queryParameters: {
      'courseId': courseId,
      'examId': examId,
      'subject': subject,
    });
    if (res.data['success'] == true && res.data['data'] != null) {
      return res.data['data'];
    }
    throw Exception(res.data['error'] ?? 'Failed to load marks sheet');
  }

  Future<void> saveMarks({
    required int courseId,
    required int examId,
    required String subject,
    required double maxMarks,
    required List<Map<String, dynamic>> marksData,
  }) async {
    final res = await _apiClient.dio.post('/exams/save-marks', data: {
      'courseId': courseId,
      'examId': examId,
      'subject': subject,
      'maxMarks': maxMarks,
      'marksData': marksData,
    });
    if (res.data['success'] != true) {
      throw Exception(res.data['error'] ?? 'Failed to save marks');
    }
  }

  // Notices for Teacher
  Future<List<Map<String, dynamic>>> getNotices({required int schoolId}) async {
    final res = await _apiClient.dio.get('/notices', queryParameters: {
      'schoolId': schoolId,
      'role': 'TEACHER',
    });
    if (res.data is List) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    if (res.data['success'] == true && res.data['data'] != null) {
      return (res.data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Feedback for Teacher
  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final res = await _apiClient.dio.get('/feedback');
    if (res.data is List) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> createFeedback({
    required String targetType,
    required int targetId,
    required String content,
  }) async {
    final res = await _apiClient.dio.post('/feedback', data: {
      'targetType': targetType,
      'targetId': targetId,
      'content': content,
    });
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(res.data['error'] ?? 'Failed to submit feedback');
    }
  }
}
