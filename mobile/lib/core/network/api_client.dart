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

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('🌐 [DIO] $obj'),
      ),
    );

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
          debugPrint(
              '❌ [DIO ERROR] ${e.requestOptions.uri} -> ${e.type}: ${e.message}');
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
      if (error.response?.data != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        } else if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your network.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to server. Please check the backend URL and network connection.';
      }
      return error.message ?? 'A network error occurred';
    }
    return error.toString();
  }
}
