import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/failure.dart';
import '../../../models/statistics.dart';
import '../data/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(const DashboardState.loading()) {
    on<DashboardFetched>(_onFetched);
  }

  Future<void> _onFetched(
    DashboardFetched event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardState.loading());
    final Either<Failure, DashboardStats> result = await repository.fetchStats();
    result.fold(
      (failure) => emit(DashboardState.error(_formatFailure(failure))),
      (stats) {
        final safeStats = stats.trends.isEmpty
            ? DashboardStats(
                totalDoctors: stats.totalDoctors,
                activeBookings: stats.activeBookings,
                totalPatients: stats.totalPatients,
                revenue: stats.revenue,
                trends: List.generate(7, (index) {
                  final date = DateTime.now().subtract(Duration(days: 6 - index));
                  return BookingTrend(date: date, count: 0);
                }),
              )
            : stats;
        emit(DashboardState.loaded(safeStats));
      },
    );
  }

  String _formatFailure(Failure failure) {
    if (failure.statusCode != null) {
      return '${failure.message} (Code ${failure.statusCode})';
    }
    return failure.message;
  }
}
