import '../../../models/api_response.dart';
import '../../../models/appointment.dart';
import '../../../services/api_service.dart';

class AppointmentsRepository {
  final ApiService api;

  AppointmentsRepository(this.api);

  Future<ApiResponse<List<Appointment>>> fetchAppointments() async {
    final response = await api.get('/api/Appointment/doctor/my-appointments');
    return ApiResponse<List<Appointment>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Appointment>> updateStatus({
    required int id,
    required AppointmentStatus status,
    String? doctorNotes,
  }) async {
    final response = await api.put('/api/Appointment/$id/status', data: {
      'status': status.value,
      'doctorNotes': doctorNotes,
    });

    return ApiResponse<Appointment>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<bool>> cancel(int id) async {
    final response = await api.post('/api/Appointment/$id/cancel');
    return ApiResponse<bool>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data == true,
    );
  }
}
