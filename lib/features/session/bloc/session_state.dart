part of 'session_bloc.dart';

// ── Modèle Participant ───────────────────────────────────────────────
class Participant extends Equatable {
  const Participant({
    required this.id,
    required this.name,
    this.score = 0,
  });

  final String id;
  final String name;
  final int score;

  Participant copyWith({int? score}) =>
      Participant(id: id, name: name, score: score ?? this.score);

  @override
  List<Object?> get props => [id, name, score];
}

// ── États ────────────────────────────────────────────────────────────
abstract class SessionState extends Equatable {
  const SessionState();
  @override
  List<Object?> get props => [];
}

/// Aucune session active
class SessionIdle extends SessionState {
  const SessionIdle();
}

/// Session LIVE en cours
class SessionActive extends SessionState {
  const SessionActive({
    required this.sessionCode,
    required this.quiz,
    required this.currentQuestionIndex,
    required this.participants,
    required this.percentA,
    required this.percentB,
  });

  final String sessionCode;
  final Quiz quiz;
  final int currentQuestionIndex;
  final List<Participant> participants;
  final int percentA;
  final int percentB;

  bool get isLastQuestion => currentQuestionIndex >= quiz.questions.length - 1;

  QuizQuestion get currentQuestion => quiz.questions[currentQuestionIndex];

  SessionActive copyWith({
    int? currentQuestionIndex,
    List<Participant>? participants,
    int? percentA,
    int? percentB,
  }) =>
      SessionActive(
        sessionCode: sessionCode,
        quiz: quiz,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
        participants: participants ?? this.participants,
        percentA: percentA ?? this.percentA,
        percentB: percentB ?? this.percentB,
      );

  @override
  List<Object?> get props =>
      [sessionCode, currentQuestionIndex, participants, percentA, percentB];
}

/// Session terminée
class SessionFinished extends SessionState {
  const SessionFinished({
    required this.quiz,
    required this.finalLeaderboard,
  });

  final Quiz quiz;
  final List<Participant> finalLeaderboard;

  @override
  List<Object?> get props => [quiz.id, finalLeaderboard];
}
