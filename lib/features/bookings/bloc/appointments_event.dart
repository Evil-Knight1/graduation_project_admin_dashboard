part of 'appointments_bloc.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class AppointmentsFetched extends AppointmentsEvent {
  const AppointmentsFetched();
}

class AppointmentStatusChanged extends AppointmentsEvent {
  final int id;
  final AppointmentStatus status;

  const AppointmentStatusChanged({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}
