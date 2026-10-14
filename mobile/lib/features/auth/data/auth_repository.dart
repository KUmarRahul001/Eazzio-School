import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_database_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  Future<LoginResponse> login({
    required String loginId,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email':
              loginId, // backend uses 'email' field to accept email, studentId or employeeId
          'password': password,
          'role': role.toServerString(),
        },
      );

      final loginRes = LoginResponse.fromJson(response.data);
      if (loginRes.success && loginRes.token != null && loginRes.user != null) {
        await _storageService.saveToken(loginRes.token!);
        await _storageService.saveUserData(loginRes.user!.toJson());
      }
      return loginRes;
    } on DioException catch (e) {
      final errorMsg = _apiClient.parseErrorMessage(e);
      return LoginResponse(success: false, error: errorMsg);
    } catch (e) {
      return LoginResponse(success: false, error: e.toString());
    }
  }

  Future<AuthUser?> getSavedUser() async {
    final data = await _storageService.getUserData();
    if (data != null) {
      return AuthUser.fromJson(data);
    }
    return null;
  }

  Future<String?> getSavedToken() async {
    return await _storageService.getToken();
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
    try {
      await LocalDatabaseService.clearUserData();
    } catch (_) {}
  }
}
