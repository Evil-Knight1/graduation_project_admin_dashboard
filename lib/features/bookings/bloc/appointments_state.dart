part of 'appointments_bloc.dart';

enum AppointmentsStatus { loading, loaded, updating, error }

class AppointmentsState extends Equatable {
  final AppointmentsStatus status;
  final List<Appointment> appointments;
  final String? message;

  const AppointmentsState._({
    required this.status,
    this.appointments = const [],
    this.message,
  });

  const AppointmentsState.loading() : this._(status: AppointmentsStatus.loading);

  const AppointmentsState.loaded(List<Appointment> appointments)
      : this._(status: AppointmentsStatus.loaded, appointments: appointments);

  const AppointmentsState.updating(List<Appointment> appointments)
      : this._(status: AppointmentsStatus.updating, appointments: appointments);

  const AppointmentsState.error(String message)
      : this._(status: AppointmentsStatus.error, message: message);

  @override
  List<Object?> get props => [status, appointments, message];
}
