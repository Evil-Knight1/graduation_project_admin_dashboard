import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/doctor.dart';
import '../../../models/paged_result.dart';
import '../data/doctors_repository.dart';

part 'doctors_event.dart';
part 'doctors_state.dart';

class DoctorsBloc extends Bloc<DoctorsEvent, DoctorsState> {
  final DoctorsRepository repository;

  DoctorsBloc(this.repository) : super(const DoctorsState()) {
    on<DoctorsFetched>(_onFetched);
    on<DoctorsPageChanged>(_onPageChanged);
    on<DoctorApproved>(_onApproved);
    on<DoctorRejected>(_onRejected);
    on<DoctorDeleted>(_onDeleted);
    on<DoctorCreated>(_onCreated);
    on<DoctorUpdated>(_onUpdated);
  }

  Future<void> _onFetched(
    DoctorsFetched event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(status: DoctorsStatus.loading, message: null));
    try {
      final response = await repository.fetchDoctors(
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );
      if (response.success && response.data != null) {
        final result = response.data as PagedResult<Doctor>;
        emit(
          state.copyWith(
            status: DoctorsStatus.loaded,
            doctors: result.items,
            totalCount: result.totalCount,
            pageNumber: result.pageNumber,
            pageSize: result.pageSize,
          ),
        );
      } else {
        emit(state.copyWith(
          status: DoctorsStatus.error,
          message: response.message ?? 'Failed to load doctors.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: DoctorsStatus.error, message: e.toString()));
    }
  }

  Future<void> _onPageChanged(
    DoctorsPageChanged event,
    Emitter<DoctorsState> emit,
  ) async {
    add(DoctorsFetched(pageNumber: event.pageNumber, pageSize: event.pageSize));
  }

  Future<void> _onApproved(
    DoctorApproved event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    await repository.approveDoctor(event.id);
    emit(state.copyWith(actionInProgress: false));
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onRejected(
    DoctorRejected event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    await repository.rejectDoctor(event.id);
    emit(state.copyWith(actionInProgress: false));
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onDeleted(
    DoctorDeleted event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    await repository.deleteUser(event.id);
    emit(state.copyWith(actionInProgress: false));
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onCreated(
    DoctorCreated event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    final response = await repository.createDoctor(
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
      password: event.password,
      licenseNumber: event.licenseNumber,
      specialization: event.specialization,
      bio: event.bio,
      yearsOfExperience: event.yearsOfExperience,
      clinicAddress: event.clinicAddress,
      hospital: event.hospital,
    );
    emit(state.copyWith(actionInProgress: false, message: response.message));
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onUpdated(
    DoctorUpdated event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    final response = await repository.updateDoctorProfile(event.doctor);
    emit(state.copyWith(actionInProgress: false, message: response.message));
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }
}
