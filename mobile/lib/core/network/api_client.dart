import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storageService;
  void Function()? onUnauthorized;

  ApiClient({SecureStorageService? storageService, this.onUnauthorized})
      : _storageService = storageService ?? SecureStorageService() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Only enable minimal logging in debug mode without sensitive body/token payload leaks
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('🌐 [HTTP] ${options.method} ${options.path}');
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            debugPrint('❌ [HTTP ERROR] ${e.requestOptions.path} [${e.response?.statusCode}] (${e.type}: ${e.message})');
            return handler.next(e);
          },
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            // Check if it's an unauthenticated token expiration
            if (e.requestOptions.path != '/auth/login') {
              await _storageService.clearAuth();
              onUnauthorized?.call();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    AppConfig.setBaseUrl(newUrl);
    dio.options.baseUrl = AppConfig.baseUrl;
  }

  static String parseError(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet connection.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to reach the school server. Please verify your internet connection.';
      }

      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          // If 401 returned from login endpoint itself, it means bad credentials
          final data = error.response?.data;
          if (data is Map<String, dynamic> && data['error'] != null) {
            return data['error'].toString();
          }
          return 'Invalid credentials. Please check your login ID and password.';
        }
        if (statusCode == 403) {
          return 'Access restricted. Please contact your school administrator.';
        }
        if (statusCode == 404) {
          return 'The requested record or resource was not found.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'School server is temporarily unavailable. Please try again shortly.';
        }

        if (data is Map<String, dynamic>) {
          final msg = data['message'] ?? data['error'];
          if (msg is String && msg.trim().isNotEmpty) {
            final lower = msg.toLowerCase();
            if (!lower.contains('prisma') &&
                !lower.contains('syntaxerror') &&
                !lower.contains('stack') &&
                !lower.contains('database') &&
                !lower.contains('column') &&
                !lower.contains('table') &&
                !lower.contains('sql')) {
              return msg.trim();
            }
          }
        }
        return 'Unable to process request. Please try again.';
      }

      return 'Unable to complete request. Please check your connection and try again.';
    }

    final errStr = error.toString();
    final lower = errStr.toLowerCase();
    if (lower.contains('dioexception') ||
        lower.contains('xmlhttprequest') ||
        lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('failed host lookup') ||
        lower.contains('network') ||
        lower.contains('cors')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    }

    if (errStr.startsWith('Exception: ')) {
      final clean = errStr.substring(11).trim();
      if (!clean.toLowerCase().contains('dioexception')) {
        return clean;
      }
    }

    return 'Unable to load data. Please check your connection and try again.';
  }

  String parseErrorMessage(dynamic error) => parseError(error);
}
