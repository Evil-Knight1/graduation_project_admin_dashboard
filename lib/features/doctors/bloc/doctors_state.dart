part of 'doctors_bloc.dart';

enum DoctorsStatus { initial, loading, loaded, error }

class DoctorsState extends Equatable {
  final DoctorsStatus status;
  final List<Doctor> doctors;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool actionInProgress;
  final String? message;

  const DoctorsState({
    this.status = DoctorsStatus.initial,
    this.doctors = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.actionInProgress = false,
    this.message,
  });

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<Doctor>? doctors,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    bool? actionInProgress,
    String? message,
  }) {
    return DoctorsState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
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
        totalCount,
        pageNumber,
        pageSize,
        actionInProgress,
        message,
      ];
}
