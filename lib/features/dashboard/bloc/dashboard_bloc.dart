import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    try {
      final response = await repository.fetchStats();
      if (response.success && response.data != null) {
        var stats = response.data as DashboardStats;
        if (stats.trends.isEmpty) {
          stats = DashboardStats(
            totalDoctors: stats.totalDoctors,
            activeBookings: stats.activeBookings,
            totalPatients: stats.totalPatients,
            revenue: stats.revenue,
            trends: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              return BookingTrend(date: date, count: 0);
            }),
          );
        }
        emit(DashboardState.loaded(stats));
      } else {
        emit(DashboardState.error(response.message ?? 'Failed to load stats.'));
      }
    } catch (e) {
      emit(DashboardState.error(e.toString()));
    }
  }
}
