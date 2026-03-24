import 'package:dio/dio.dart';
import '../core/constants.dart';
import 'secure_storage_service.dart';

class ApiService {
  final Dio dio;
  final SecureStorageService storage;

  ApiService({required this.storage})
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            validateStatus: (status) => status != null && status < 500,
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    return dio.get(path, queryParameters: query);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return dio.post(path, data: data);
  }

  Future<Response<dynamic>> put(String path, {dynamic data}) async {
    return dio.put(path, data: data);
  }

  Future<Response<dynamic>> delete(String path) async {
    return dio.delete(path);
  }
}
