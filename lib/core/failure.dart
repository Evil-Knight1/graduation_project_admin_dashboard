import 'package:dio/dio.dart';

class Failure {
  final String message;
  final int? statusCode;

  Failure({required this.message, this.statusCode});

  factory Failure.fromDio(DioException error) {
    final response = error.response;
    String message = 'Unexpected error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet.';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect to the server. Please check if the server is running or your network connection.';
        break;
      case DioExceptionType.badResponse:
        if (response?.data is Map<String, dynamic>) {
          final data = response?.data as Map<String, dynamic>;
          message = data['message']?.toString() ?? 'Server error';
          if (data['errors'] is List) {
            final errors = (data['errors'] as List).map((e) => e.toString()).join(', ');
            if (errors.isNotEmpty) message = errors;
          }
        } else {
          message = 'Server returned an error (${response?.statusCode})';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      default:
        // Handle generic network errors that often manifest as "XMLHttpRequest onError" on web
        if (error.message?.contains('XMLHttpRequest') == true) {
          message = 'Network error: The server might be unreachable or CORS is not configured correctly.';
        } else {
          message = error.message ?? 'A network error occurred';
        }
    }

    return Failure(message: message, statusCode: response?.statusCode);
  }
}
