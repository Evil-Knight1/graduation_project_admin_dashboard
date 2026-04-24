import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/failure.dart';
import '../../../models/api_response.dart';
import '../../../models/doctor.dart';
import '../../../models/paged_result.dart';
import '../../../services/api_service.dart';

class DoctorsRepository {
  final ApiService api;

  DoctorsRepository(this.api);

  Future<Either<Failure, PagedResult<Doctor>>> fetchDoctors({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await api.get('/api/Admin/doctors', query: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      });

      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }

      final parsed = ApiResponse<PagedResult<Doctor>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PagedResult.fromJson(
          data as Map<String, dynamic>,
          (item) => Doctor.fromJson(item),
        ),
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as PagedResult<Doctor>);
      }
      return Left(
          Failure(message: parsed.message ?? 'Failed to load doctors.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> approveDoctor(int id) async {
    try {
      final response = await api.post('/api/Admin/doctors/$id/approve');
      return _booleanResponse(response.data);
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    }
  }

  Future<Either<Failure, bool>> rejectDoctor(int id) async {
    try {
      final response = await api.post('/api/Admin/doctors/$id/reject');
      return _booleanResponse(response.data);
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    }
  }

  Future<Either<Failure, bool>> deleteUser(int id) async {
    try {
      final response = await api.delete('/api/Admin/users/$id');
      return _booleanResponse(response.data);
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    }
  }

  Future<Either<Failure, Doctor>> updateDoctorProfile(Doctor doctor) async {
    try {
      final response =
          await api.put('/api/Doctor/profile', data: doctor.toUpdateJson());
      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }
      final parsed = ApiResponse<Doctor>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Doctor.fromJson(data as Map<String, dynamic>),
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as Doctor);
      }
      return Left(
          Failure(message: parsed.message ?? 'Failed to update doctor.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<String>>> fetchSpecializations() async {
    try {
      final response = await api.get('/api/Doctor/specializations');
      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }
      final parsed = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data!.map((e) => e.toString()).toList());
      }
      return Left(Failure(
          message: parsed.message ?? 'Failed to load specializations.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> createDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    List<String>? specializations,
    String? bio,
    int? yearsOfExperience,
    String? clinicAddress,
    String? hospital,
  }) async {
    try {
      debugPrint("Creating doctor...");
      debugPrint('fullName: $fullName');
      debugPrint('email: $email');
      debugPrint('phone: $phone');
      debugPrint('password: $password');
      debugPrint('licenseNumber: $licenseNumber');
      debugPrint('specializations: $specializations');
      debugPrint('bio: $bio');
      debugPrint('yearsOfExperience: $yearsOfExperience');
      debugPrint('clinicAddress: $clinicAddress');
      debugPrint('hospital: $hospital');
      final response = await api.post('/api/Auth/register/doctor', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'licenseNumber': licenseNumber,
        'specialization': specializations
            ?.join(', '), // Send as comma separated if backend expects string
        'bio': bio,
        'yearsOfExperience': yearsOfExperience,
        'clinicAddress': clinicAddress,
        'hospital': hospital,
      });

      return _booleanResponse(response.data);
    } on DioException catch (e) {
      debugPrint(e.response!.data.toString());
      return Left(Failure.fromDio(e));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(message: e.toString()));
    }
  }

  Either<Failure, bool> _booleanResponse(dynamic data) {
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

    String errorMsg = parsed.message ?? 'Failed to add doctor.';
    if (parsed.errors != null && parsed.errors!.isNotEmpty) {
      errorMsg = parsed.errors!.join('\n');
    }
    debugPrint(errorMsg);
    return Left(Failure(message: errorMsg));
  }
}
