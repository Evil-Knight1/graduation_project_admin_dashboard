import 'package:dio/dio.dart';

class Failure {
  final String message;
  final int? statusCode;

  Failure({required this.message, this.statusCode});

  factory Failure.fromDio(DioException error) {
    final response = error.response;
    String message = error.message ?? 'Unexpected error';

    if (response?.data is Map<String, dynamic>) {
      final data = response?.data as Map<String, dynamic>;
      message = data['message']?.toString() ?? message;
      if (data['errors'] is List) {
        final errors = (data['errors'] as List).map((e) => e.toString()).join(', ');
        if (errors.isNotEmpty) {
          message = errors;
        }
      }
    }

    return Failure(message: message, statusCode: response?.statusCode);
  }
}
