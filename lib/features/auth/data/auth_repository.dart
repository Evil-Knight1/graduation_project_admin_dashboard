import '../../../models/api_response.dart';
import '../../../models/auth_response.dart';
import '../../../services/api_service.dart';

class AuthRepository {
  final ApiService api;

  AuthRepository(this.api);

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await api.post('/api/Auth/login', data: {
      'email': email,
      'password': password,
    });

    return ApiResponse<AuthResponse>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}
