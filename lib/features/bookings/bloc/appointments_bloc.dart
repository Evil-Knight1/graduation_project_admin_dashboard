import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    try {
      final response = await repository.fetchAppointments();
      if (response.success && response.data != null) {
        emit(AppointmentsState.loaded(response.data as List<Appointment>));
      } else {
        emit(AppointmentsState.error(response.message ?? 'Failed to load.'));
      }
    } catch (e) {
      emit(AppointmentsState.error(e.toString()));
    }
  }

  Future<void> _onStatusChanged(
    AppointmentStatusChanged event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state.status != AppointmentsStatus.loaded) return;
    emit(AppointmentsState.updating(state.appointments));
    try {
      if (event.status == AppointmentStatus.cancelled) {
        await repository.cancel(event.id);
      } else {
        await repository.updateStatus(id: event.id, status: event.status);
      }
      add(const AppointmentsFetched());
    } catch (e) {
      emit(AppointmentsState.error(e.toString()));
    }
  }
}
