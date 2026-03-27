part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();
  @override
  List<Object?> get props => [];
}

/// Démarrer une session avec un quiz donné
class StartSession extends SessionEvent {
  const StartSession({required this.quiz});
  final Quiz quiz;
  @override
  List<Object?> get props => [quiz.id];
}

/// Passer à la question suivante
class NextQuestion extends SessionEvent {
  const NextQuestion();
}

/// Terminer la session
class EndSession extends SessionEvent {
  const EndSession();
}
