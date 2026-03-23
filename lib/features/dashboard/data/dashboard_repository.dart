import '../../../models/api_response.dart';
import '../../../models/statistics.dart';
import '../../../services/api_service.dart';

class DashboardRepository {
  final ApiService api;

  DashboardRepository(this.api);

  Future<ApiResponse<DashboardStats>> fetchStats() async {
    final response = await api.get('/api/Admin/statistics');
    return ApiResponse<DashboardStats>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => DashboardStats.fromJson(data as Map<String, dynamic>),
    );
  }
}
