import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/patients_repository.dart';
import 'patients_event.dart';
import 'patients_state.dart';

class PatientsBloc extends Bloc<PatientsEvent, PatientsState> {
  final PatientsRepository repository;

  PatientsBloc(this.repository) : super(PatientsInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<DeletePatientRequested>(_onDeletePatientRequested);
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientsState> emit,
  ) async {
    emit(PatientsLoading());
    final result = await repository.fetchPatients(
      pageNumber: event.pageNumber,
      pageSize: event.pageSize,
    );
    result.fold(
      (failure) => emit(PatientsError(failure.message)),
      (pagedResult) => emit(PatientsLoaded(pagedResult)),
    );
  }

  Future<void> _onDeletePatientRequested(
    DeletePatientRequested event,
    Emitter<PatientsState> emit,
  ) async {
    final result = await repository.deletePatient(event.id);
    result.fold(
      (failure) => emit(PatientsError(failure.message)),
      (_) {
        emit(const PatientOperationSuccess('Patient deleted successfully'));
        add(const LoadPatients());
      },
    );
  }
}
