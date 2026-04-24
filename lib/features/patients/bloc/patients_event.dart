import 'package:equatable/equatable.dart';

abstract class PatientsEvent extends Equatable {
  const PatientsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientsEvent {
  final int pageNumber;
  final int pageSize;

  const LoadPatients({this.pageNumber = 1, this.pageSize = 10});

  @override
  List<Object?> get props => [pageNumber, pageSize];
}

class DeletePatientRequested extends PatientsEvent {
  final int id;

  const DeletePatientRequested(this.id);

  @override
  List<Object?> get props => [id];
}
