import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/graphql_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(_initialState()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthRequested>(_onCheckAuthRequested);

    // Charger le userId si déjà connecté
    if (state is AuthAuthenticated) {
      print('🔐 AuthBloc init - Already authenticated, loading userId');
      add(const CheckAuthRequested());
    }
  }

  static AuthState _initialState() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔐 _initialState - Firebase user: ${user?.uid}');
    if (user != null) {
      return AuthAuthenticated(
        email: user.email ?? '',
        displayName: user.displayName,
        userId: null, // Will be loaded asynchronously
      );
    }
    return const AuthInitial();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final email = credential.user?.email ?? event.email;
      final displayName = credential.user?.displayName;
      final firebaseUid = credential.user?.uid;

      // Récupérer le vrai userId PostgreSQL via Firebase UID
      final postgresUserId = await GraphQLService.instance
          .getUserIdByFirebaseUid(firebaseUid ?? '');

      print(
          '✅ Login successful - Firebase UID: $firebaseUid, PostgreSQL ID: $postgresUserId');

      emit(AuthAuthenticated(
        email: email,
        displayName: displayName,
        userId: postgresUserId,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _mapFirebaseError(e.code)));
    } catch (_) {
      emit(const AuthError(message: 'Erreur inattendue, veuillez reessayer.'));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // ÉTAPE 1 : Créer user dans Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Mettre à jour le displayName dans Firebase
      await credential.user?.updateDisplayName(event.displayName);

      // ÉTAPE 2 : Créer user dans PostgreSQL via GraphQL
      final firebaseUid = credential.user?.uid;
      final postgresUserId = await GraphQLService.instance.createUser(
        displayName: event.displayName,
        firebaseUid: firebaseUid ?? '',
        role: 'user',
      );

      if (postgresUserId == null) {
        emit(const AuthError(
          message:
              'Erreur: Impossible de creer le compte dans la base de donnees.',
        ));
        return;
      }

      final email = credential.user?.email ?? event.email;
      print('✅ Signup successful - PostgreSQL ID: $postgresUserId');

      emit(AuthAuthenticated(
        email: email,
        userId: postgresUserId,
        displayName: event.displayName,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _mapFirebaseSignupError(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Erreur: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await FirebaseAuth.instance.signOut();
    emit(const AuthInitial());
  }

  Future<void> _onCheckAuthRequested(
    CheckAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 CheckAuthRequested triggered');
    final currentState = state;
    print('🔐 Current state: $currentState');
    if (currentState is! AuthAuthenticated) {
      print('🔐 Not authenticated, returning');
      return;
    }
    if (currentState.userId != null) {
      print('🔐 UserId already set: ${currentState.userId}');
      return;
    }

    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    print('🔐 FirebaseUid: $firebaseUid');
    if (firebaseUid == null) {
      emit(const AuthInitial());
      return;
    }

    try {
      final userId =
          await GraphQLService.instance.getUserIdByFirebaseUid(firebaseUid);
      print('🔐 Retrieved PostgreSQL userId: $userId');
      if (userId != null) {
        emit(AuthAuthenticated(
          email: currentState.email,
          userId: userId,
          displayName: currentState.displayName,
        ));
        print('✅ Updated AuthAuthenticated with PostgreSQL userId: $userId');
      } else {
        print('❌ userId is null from GraphQL');
      }
    } catch (e) {
      print('❌ Error loading userId: $e');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
        return 'Aucun utilisateur trouve avec cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Reessayez plus tard.';
      case 'network-request-failed':
        return 'Probleme reseau. Verifiez votre connexion.';
      default:
        return 'Connexion impossible ($code).';
    }
  }

  String _mapFirebaseSignupError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'email-already-in-use':
        return 'Cet email est deja utilise.';
      case 'weak-password':
        return 'Le mot de passe doit avoir au moins 6 caracteres.';
      case 'operation-not-allowed':
        return 'La creation de compte est actuellement desactivee.';
      case 'network-request-failed':
        return 'Probleme reseau. Verifiez votre connexion.';
      default:
        return 'Erreur lors de la creation du compte ($code).';
    }
  }
}
