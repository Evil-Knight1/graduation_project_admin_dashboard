import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/failure.dart';
import '../../../models/appointment.dart';
import '../data/appointments_repository.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentsRepository repository;

  AppointmentsBloc(this.repository) : super(const AppointmentsState.loading()) {
    on<AppointmentsFetched>(_onFetched);
    on<AppointmentStatusChanged>(_onStatusChanged);
  }

  Future<void> _onFetched(
    AppointmentsFetched event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(const AppointmentsState.loading());
    final Either<Failure, List<Appointment>> result =
        await repository.fetchAppointments();
    result.fold(
      (failure) => emit(AppointmentsState.error(_formatFailure(failure))),
      (appointments) => emit(AppointmentsState.loaded(appointments)),
    );
  }

  Future<void> _onStatusChanged(
    AppointmentStatusChanged event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state.status != AppointmentsStatus.loaded) return;
    emit(AppointmentsState.updating(state.appointments));
    if (event.status == AppointmentStatus.cancelled) {\n      final cancelResult = await repository.cancel(event.id);\n      cancelResult.fold(\n        (failure) => emit(AppointmentsState.error(_formatFailure(failure))),\n        (_) => add(const AppointmentsFetched()),\n      );\n      return;\n    }\n\n    final result = await repository.updateStatus(id: event.id, status: event.status);\n    result.fold(\n      (failure) => emit(AppointmentsState.error(_formatFailure(failure))),\n      (_) => add(const AppointmentsFetched()),\n    );
  }

  String _formatFailure(Failure failure) {
    if (failure.statusCode != null) {
      return '${failure.message} (Code ${failure.statusCode})';
    }
    return failure.message;
  }
}

