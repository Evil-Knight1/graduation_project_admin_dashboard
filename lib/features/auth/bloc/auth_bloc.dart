import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/failure.dart';
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
    final Either<Failure, AuthResponse> result =
        await repository.login(email: event.email, password: event.password);

    result.fold(
      (failure) => emit(AuthState.error(_formatFailure(failure))),
      (auth) async {
        await storage.saveTokens(token: auth.token, refreshToken: auth.refreshToken);
        emit(const AuthState.authenticated());
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await storage.clear();
    emit(const AuthState.unauthenticated());
  }

  String _formatFailure(Failure failure) {
    if (failure.statusCode != null) {
      return '${failure.message} (Code ${failure.statusCode})';
    }
    return failure.message;
  }
}
