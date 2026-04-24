import 'package:equatable/equatable.dart';
import '../../../models/patient.dart';
import '../../../models/paged_result.dart';

abstract class PatientsState extends Equatable {
  const PatientsState();

  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final PagedResult<Patient> result;

  const PatientsLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

class PatientsError extends PatientsState {
  final String message;

  const PatientsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientOperationSuccess extends PatientsState {
  final String message;

  const PatientOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
