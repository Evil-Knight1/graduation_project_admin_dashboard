part of 'doctors_bloc.dart';

enum DoctorsStatus { initial, loading, loaded, error }

class DoctorsState extends Equatable {
  final DoctorsStatus status;
  final List<Doctor> doctors;
  final List<String> specializations;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool actionInProgress;
  final String? message;

  const DoctorsState({
    this.status = DoctorsStatus.initial,
    this.doctors = const [],
    this.specializations = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.actionInProgress = false,
    this.message,
  });

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<Doctor>? doctors,
    List<String>? specializations,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    bool? actionInProgress,
    String? message,
  }) {
    return DoctorsState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      specializations: specializations ?? this.specializations,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctors,
        specializations,
        totalCount,
        pageNumber,
        pageSize,
        actionInProgress,
        message,
      ];
}
