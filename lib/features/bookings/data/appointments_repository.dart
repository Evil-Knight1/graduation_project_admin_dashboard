import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/failure.dart';
import '../../../models/api_response.dart';
import '../../../models/appointment.dart';
import '../../../services/api_service.dart';

class AppointmentsRepository {
  final ApiService api;

  AppointmentsRepository(this.api);

  Future<Either<Failure, List<Appointment>>> fetchAppointments() async {
    try {
      final response = await api.get('/api/Appointment/doctor/my-appointments');
      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }
      final parsed = ApiResponse<List<Appointment>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List)
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as List<Appointment>);
      }
      return Left(
          Failure(message: parsed.message ?? 'Failed to load appointments.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, Appointment>> updateStatus({
    required int id,
    required AppointmentStatus status,
    String? doctorNotes,
  }) async {
    try {
      final response = await api.put('/api/Appointment/$id/status', data: {
        'status': status.value,
        'doctorNotes': doctorNotes,
      });

      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }

      final parsed = ApiResponse<Appointment>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Appointment.fromJson(data as Map<String, dynamic>),
      );

      if (parsed.success && parsed.data != null) {
        return Right(parsed.data as Appointment);
      }
      return Left(
          Failure(message: parsed.message ?? 'Failed to update status.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> cancel(int id) async {
    try {
      final response = await api.post('/api/Appointment/$id/cancel');
      if (response.data is! Map<String, dynamic>) {
        return Left(Failure(message: 'Invalid response from server.'));
      }
      final parsed = ApiResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data == true,
      );
      if (parsed.success) {
        return Right(parsed.data == true);
      }
      return Left(Failure(message: parsed.message ?? 'Failed to cancel.'));
    } on DioException catch (e) {
      return Left(Failure.fromDio(e));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
