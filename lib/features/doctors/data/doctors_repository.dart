import '../../../models/api_response.dart';
import '../../../models/doctor.dart';
import '../../../models/paged_result.dart';
import '../../../services/api_service.dart';

class DoctorsRepository {
  final ApiService api;

  DoctorsRepository(this.api);

  Future<ApiResponse<PagedResult<Doctor>>> fetchDoctors({
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await api.get('/api/Admin/doctors', query: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });

    return ApiResponse<PagedResult<Doctor>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PagedResult.fromJson(
        data as Map<String, dynamic>,
        (item) => Doctor.fromJson(item),
      ),
    );
  }

  Future<ApiResponse<bool>> approveDoctor(int id) async {
    final response = await api.post('/api/Admin/doctors/$id/approve');
    return ApiResponse<bool>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data == true,
    );
  }

  Future<ApiResponse<bool>> rejectDoctor(int id) async {
    final response = await api.post('/api/Admin/doctors/$id/reject');
    return ApiResponse<bool>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data == true,
    );
  }

  Future<ApiResponse<bool>> deleteUser(int id) async {
    final response = await api.delete('/api/Admin/users/$id');
    return ApiResponse<bool>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data == true,
    );
  }

  Future<ApiResponse<Doctor>> updateDoctorProfile(Doctor doctor) async {
    final response =
        await api.put('/api/Doctor/profile', data: doctor.toUpdateJson());
    return ApiResponse<Doctor>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => Doctor.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<bool>> createDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    String? specialization,
    String? bio,
    int? yearsOfExperience,
    String? clinicAddress,
    String? hospital,
  }) async {
    final response = await api.post('/api/Auth/register/doctor', data: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'clinicAddress': clinicAddress,
      'hospital': hospital,
    });

    return ApiResponse<bool>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data != null,
    );
  }
}
