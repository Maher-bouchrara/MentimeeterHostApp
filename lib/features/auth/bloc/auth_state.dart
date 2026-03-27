part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// État initial — aucune action
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Connexion en cours (loading)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Connecté avec succès
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.email});
  final String email;
  @override
  List<Object?> get props => [email];
}

/// Erreur de connexion
class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
