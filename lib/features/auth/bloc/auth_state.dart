part of 'auth_bloc.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? message;

  const AuthState._({required this.status, this.message});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, message: message);

  @override
  List<Object?> get props => [status, message];
}
