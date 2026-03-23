part of 'dashboard_bloc.dart';

enum DashboardStatus { loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardStats? stats;
  final String? message;

  const DashboardState._({required this.status, this.stats, this.message});

  const DashboardState.loading() : this._(status: DashboardStatus.loading);

  const DashboardState.loaded(DashboardStats stats)
      : this._(status: DashboardStatus.loaded, stats: stats);

  const DashboardState.error(String message)
      : this._(status: DashboardStatus.error, message: message);

  @override
  List<Object?> get props => [status, stats, message];
}
