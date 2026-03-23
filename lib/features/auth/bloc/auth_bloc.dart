import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/auth_response.dart';
import '../../../services/secure_storage_service.dart';
import '../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final SecureStorageService storage;

  AuthBloc({required this.repository, required this.storage})
      : super(const AuthState.unknown()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = await storage.readToken();
    if (token != null && token.isNotEmpty) {
      emit(const AuthState.authenticated());
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final response = await repository.login(
        email: event.email,
        password: event.password,
      );
      if (response.success && response.data != null) {
        final auth = response.data as AuthResponse;
        await storage.saveTokens(
          token: auth.token,
          refreshToken: auth.refreshToken,
        );
        emit(const AuthState.authenticated());
      } else {
        emit(AuthState.error(response.message ?? 'Login failed.'));
      }
    } catch (e) {
      emit(AuthState.error('Login failed. ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await storage.clear();
    emit(const AuthState.unauthenticated());
  }
}
