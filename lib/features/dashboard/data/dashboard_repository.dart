import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/failure.dart';
import '../../../models/api_response.dart';
import '../../../models/statistics.dart';
import '../../../services/api_service.dart';

class DashboardRepository {
  final ApiService api;

  DashboardRepository(this.api);

  Future<Either<Failure, DashboardStats>> fetchStats() async {
    try {
      final response = await api.get('/api/Admin/statistics');
      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }
      final parsed = ApiResponse<DashboardStats>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => DashboardStats.fromJson(data as Map<String, dynamic>),
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as DashboardStats);
      }
      return Left(Failure(message: parsed.message ?? 'Failed to load stats.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
