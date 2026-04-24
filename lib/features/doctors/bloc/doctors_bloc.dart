import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/failure.dart';
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
    on<SpecializationsFetched>(_onSpecializationsFetched);
  }

  Future<void> _onFetched(
    DoctorsFetched event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(status: DoctorsStatus.loading, message: null));
    final Either<Failure, PagedResult<Doctor>> result =
        await repository.fetchDoctors(
      pageNumber: event.pageNumber,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: DoctorsStatus.error,
        message: _formatFailure(failure),
      )),
      (result) => emit(
        state.copyWith(
          status: DoctorsStatus.loaded,
          doctors: result.items,
          totalCount: result.totalCount,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        ),
      ),
    );
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
    final result = await repository.approveDoctor(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
          actionInProgress: false, message: _formatFailure(failure))),
      (_) => emit(state.copyWith(actionInProgress: false)),
    );
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onRejected(
    DoctorRejected event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    final result = await repository.rejectDoctor(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
          actionInProgress: false, message: _formatFailure(failure))),
      (_) => emit(state.copyWith(actionInProgress: false)),
    );
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onDeleted(
    DoctorDeleted event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    final result = await repository.deleteUser(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
          actionInProgress: false, message: _formatFailure(failure))),
      (_) => emit(state.copyWith(actionInProgress: false)),
    );
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onCreated(
    DoctorCreated event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    final result = await repository.createDoctor(
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
      password: event.password,
      licenseNumber: event.licenseNumber,
      specializations: event.specializations,
      bio: event.bio,
      yearsOfExperience: event.yearsOfExperience,
      clinicAddress: event.clinicAddress,
      hospital: event.hospital,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          actionInProgress: false, message: _formatFailure(failure))),
      (_) => emit(state.copyWith(actionInProgress: false)),
    );
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onUpdated(
    DoctorUpdated event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    final result = await repository.updateDoctorProfile(event.doctor);
    result.fold(
      (failure) => emit(state.copyWith(
          actionInProgress: false, message: _formatFailure(failure))),
      (_) => emit(state.copyWith(actionInProgress: false)),
    );
    add(DoctorsFetched(pageNumber: state.pageNumber, pageSize: state.pageSize));
  }

  Future<void> _onSpecializationsFetched(
    SpecializationsFetched event,
    Emitter<DoctorsState> emit,
  ) async {
    final result = await repository.fetchSpecializations();
    result.fold(
      (failure) => emit(state.copyWith(message: _formatFailure(failure))),
      (specializations) => emit(state.copyWith(specializations: specializations)),
    );
  }

  String _formatFailure(Failure failure) {
    if (failure.statusCode != null) {
      return '${failure.message} (Code ${failure.statusCode})';
    }
    return failure.message;
  }
}
