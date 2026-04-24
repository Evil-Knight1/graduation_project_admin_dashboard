import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/failure.dart';
import '../../../models/api_response.dart';
import '../../../models/patient.dart';
import '../../../models/paged_result.dart';
import '../../../services/api_service.dart';

class PatientsRepository {
  final ApiService api;

  PatientsRepository(this.api);

  Future<Either<Failure, PagedResult<Patient>>> fetchPatients({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await api.get('/api/Admin/patients', query: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      });

      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }

      final parsed = ApiResponse<PagedResult<Patient>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PagedResult.fromJson(
          data as Map<String, dynamic>,
          (item) => Patient.fromJson(item),
        ),
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as PagedResult<Patient>);
      }
      return Left(
          Failure(message: parsed.message ?? 'Failed to load patients.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deletePatient(int id) async {
    try {
      final response = await api.delete('/api/Admin/users/$id');
      return _booleanResponse(response.data);
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    }
  }

  Either<Failure, bool> _booleanResponse(dynamic data,
      {String? fallbackMessage}) {
    if (data is! Map<String, dynamic>) {
      return Left(Failure(message: 'Invalid response from server.'));
    }
    final parsed = ApiResponse<bool>.fromJson(
      data,
      (value) => value == true,
    );
    if (parsed.success) {
      return Right(parsed.data == true);
    }
    return Left(Failure(
        message: parsed.message ?? fallbackMessage ?? 'Operation failed.'));
  }
}
