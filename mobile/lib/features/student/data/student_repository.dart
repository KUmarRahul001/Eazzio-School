import '../../../core/network/api_client.dart';
import '../models/student_models.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository(this._apiClient);

  Future<StudentDashboardData> getDashboardSummary() async {
    final res = await _apiClient.dio.get('/student/dashboard-summary');
    if (res.data['success'] == true && res.data['data'] != null) {
      return StudentDashboardData.fromJson(res.data['data']);
    }
    throw Exception(res.data['error'] ?? 'Failed to load dashboard summary');
  }

  Future<StudentFullProfile> getProfile() async {
    final res = await _apiClient.dio.get('/student/profile');
    if (res.data['success'] == true && res.data['data'] != null) {
      return StudentFullProfile.fromJson(res.data['data']);
    }
    throw Exception(res.data['error'] ?? 'Failed to load profile');
  }

  Future<StudentFullProfile> updateProfile({String? phone}) async {
    final res =
        await _apiClient.dio.put('/student/profile', data: {'phone': phone});
    if (res.data['success'] == true && res.data['data'] != null) {
      return StudentFullProfile.fromJson(res.data['data']);
    }
    throw Exception(res.data['error'] ?? 'Failed to update profile');
  }

  Future<Map<String, dynamic>> getAttendance() async {
    final res = await _apiClient.dio.get('/student/attendance');
    if (res.data['success'] == true && res.data['data'] != null) {
      final data = res.data['data'];
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final recordsRaw = (data['records'] as List? ?? []);
      final records =
          recordsRaw.map((r) => AttendanceRecord.fromJson(r)).toList();
      return {
        'stats': stats,
        'records': records,
      };
    }
    throw Exception(res.data['error'] ?? 'Failed to load attendance');
  }

  Future<Map<String, List<RoutineItem>>> getRoutine() async {
    final res = await _apiClient.dio.get('/student/routine');
    if (res.data['success'] == true && res.data['data'] != null) {
      final Map<String, dynamic> rawMap = res.data['data'];
      final Map<String, List<RoutineItem>> result = {};
      rawMap.forEach((day, items) {
        if (items is List) {
          result[day] = items.map((i) => RoutineItem.fromJson(i)).toList();
        }
      });
      return result;
    }
    throw Exception(res.data['error'] ?? 'Failed to load routine');
  }

  Future<List<FeeInvoiceItem>> getFees() async {
    final res = await _apiClient.dio.get('/student/fees');
    if (res.data['success'] == true && res.data['data'] != null) {
      final invoices = res.data['data']['invoices'] as List? ?? [];
      return invoices.map((i) => FeeInvoiceItem.fromJson(i)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load fees');
  }

  Future<Map<String, dynamic>> createFeeOrder(int invoiceId) async {
    final res = await _apiClient.dio.post('/student/fees/create-order', data: {
      'invoiceId': invoiceId,
    });
    if (res.data['success'] == true && res.data['data'] != null) {
      return res.data['data'];
    }
    throw Exception(res.data['error'] ?? 'Failed to create fee order');
  }

  Future<bool> verifyPayment({
    required int invoiceId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final res =
        await _apiClient.dio.post('/student/fees/verify-payment', data: {
      'invoiceId': invoiceId,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    });
    return res.data['success'] == true;
  }

  Future<List<AssignmentItem>> getAssignments() async {
    final res = await _apiClient.dio.get('/student/assignments');
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data'] as List;
      return list.map((a) => AssignmentItem.fromJson(a)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load assignments');
  }

  Future<StudentResultGroup> getResults() async {
    final res = await _apiClient.dio.get('/student/results');
    if (res.data['success'] == true && res.data['data'] != null) {
      return StudentResultGroup.fromJson(res.data['data']);
    }
    throw Exception(res.data['error'] ?? 'Failed to load results');
  }

  Future<List<NoticeItem>> getNotices() async {
    final res = await _apiClient.dio.get('/student/notices');
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data'] as List;
      return list.map((n) => NoticeItem.fromJson(n)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load notices');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _apiClient.dio.put('/student/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (res.data['success'] != true) {
      throw Exception(res.data['error'] ?? 'Failed to change password');
    }
  }

  Future<List<ExamTimetableItem>> getExamTimetables({String? examType}) async {
    final queryParams = <String, dynamic>{};
    if (examType != null && examType != 'ALL') {
      queryParams['examType'] = examType;
    }
    final res = await _apiClient.dio
        .get('/exams/timetable/list', queryParameters: queryParams);
    if (res.data['success'] == true && res.data['data'] != null) {
      final list = res.data['data'] as List;
      return list.map((t) => ExamTimetableItem.fromJson(t)).toList();
    }
    throw Exception(res.data['error'] ?? 'Failed to load exam schedules');
  }

  Future<Map<String, dynamic>> getReceipt(int paymentId) async {
    final res = await _apiClient.dio.get('/student/fees/receipt/$paymentId');
    if (res.data['success'] == true && res.data['data'] != null) {
      return res.data['data'] as Map<String, dynamic>;
    }
    throw Exception(res.data['error'] ?? 'Failed to load receipt');
  }
}
