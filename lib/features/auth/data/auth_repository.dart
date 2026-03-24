import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../models/api_response.dart';
import '../../../models/auth_response.dart';
import '../../../services/api_service.dart';
import '../../../core/failure.dart';

class AuthRepository {
  final ApiService api;

  AuthRepository(this.api);

  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await api.post('/api/Auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }

      final parsed = ApiResponse<AuthResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as AuthResponse);
      }
      return Left(Failure(message: parsed.message ?? 'Login failed.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
