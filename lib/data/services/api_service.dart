// lib/data/services/api_service.dart

import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';

class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    // 1. Logger (dev only)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
    
    // 2. Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if exists
          final token = _getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Auto-refresh token on 401
          if (error.response?.statusCode == 401) {
            // TODO: Refresh token logic
          }
          return handler.next(error);
        },
      ),
    );
    
    // 3. Retry interceptor (optionnel)
    // _dio.interceptors.add(
    //   RetryInterceptor(
    //     dio: _dio,
    //     retries: 3,
    //     retryDelays: [
    //       Duration(seconds: 1),
    //       Duration(seconds: 2),
    //       Duration(seconds: 3),
    //     ],
    //   ),
    // );
  }
  
  String? _getStoredToken() {
    // TODO: Get from secure storage
    return null;
  }
  
  // GET
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // PATCH
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE
  Future<Map<String, dynamic>> delete(
    String path, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Upload file
  Future<Map<String, dynamic>> uploadFile(
    String path,
    String filePath, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode != null && 
        response.statusCode! >= 200 && 
        response.statusCode! < 300) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('⏱️ Timeout: Vérifie ta connexion');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Erreur';
        
        if (statusCode == 404) return Exception('🔍 Non trouvé');
        if (statusCode == 401) return Exception('🔐 Non autorisé');
        if (statusCode == 403) return Exception('🚫 Accès refusé');
        if (statusCode! >= 500) return Exception('🔥 Erreur serveur');
        
        return Exception('❌ $statusCode: $message');
      
      case DioExceptionType.cancel:
        return Exception('❌ Requête annulée');
      
      case DioExceptionType.connectionError:
        return Exception('📡 Pas de connexion au serveur');
      
      default:
        return Exception('❌ ${error.message}');
    }
  }
  
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  void dispose() {
    _dio.close();
  }
}