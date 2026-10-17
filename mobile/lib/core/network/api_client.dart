import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

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
            debugPrint('❌ [HTTP ERROR] ${e.requestOptions.path} [${e.response?.statusCode}]');
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

  String parseErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        if (statusCode == 401 || statusCode == 403) {
          return 'Access denied or session expired. Please sign in again.';
        }
        if (statusCode == 404) {
          return 'The requested resource was not found.';
        }
        if (statusCode >= 500) {
          return 'Service temporarily unavailable. Please try again later.';
        }
      }

      if (error.response?.data != null) {
        final data = error.response?.data;
        String? msg;
        if (data is Map) {
          if (data.containsKey('error') && data['error'] is String) {
            msg = data['error'] as String;
          } else if (data.containsKey('message') && data['message'] is String) {
            msg = data['message'] as String;
          }
        }
        if (msg != null && msg.isNotEmpty) {
          // Guard against raw SQL/Prisma or internal stack trace leaks
          final lower = msg.toLowerCase();
          if (lower.contains('prisma') ||
              lower.contains('sql') ||
              lower.contains('database') ||
              lower.contains('syntax') ||
              lower.contains('column') ||
              lower.contains('table') ||
              lower.contains('exception') ||
              lower.contains('stack') ||
              lower.contains('query') ||
              lower.contains('neon') ||
              lower.contains('jwt')) {
            return 'An unexpected error occurred. Please try again.';
          }
          return msg;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Please try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to server. Please check your network connection.';
      }
      return 'Unable to complete request. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
