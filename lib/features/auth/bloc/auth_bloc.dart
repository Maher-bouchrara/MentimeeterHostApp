import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Mock : accepte n'importe quel email non-vide + mot de passe >= 4 chars
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Simulation d'un appel réseau
    await Future.delayed(const Duration(milliseconds: 800));

    if (event.email.isEmpty || event.password.length < 4) {
      emit(const AuthError(message: 'Email ou mot de passe invalide'));
      return;
    }

    emit(AuthAuthenticated(email: event.email));
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }
}
