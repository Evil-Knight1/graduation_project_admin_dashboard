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
    await result.fold(
      (failure) async => emit(DashboardState.error(_formatFailure(failure))),
      (stats) async => emit(DashboardState.loaded(stats)),
    );
  }

  String _formatFailure(Failure failure) {
    if (failure.statusCode != null) {
      return '${failure.message} (Code ${failure.statusCode})';
    }
    return failure.message;
  }
}
