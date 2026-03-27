import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../quizzes/bloc/quiz_bloc.dart';
import '../../../core/mock_data.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionIdle()) {
    on<StartSession>(_onStartSession);
    on<NextQuestion>(_onNextQuestion);
    on<EndSession>(_onEndSession);
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<SessionState> emit,
  ) async {
    // Simulation délai réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Participants mock
    final participants = MockData.participants
        .map((p) => Participant(id: p.id, name: p.name, score: p.score))
        .toList();

    final dist = MockData.answerDistributions[0];

    emit(SessionActive(
      sessionCode: MockData.sessionCode,
      quiz: event.quiz,
      currentQuestionIndex: 0,
      participants: participants,
      percentA: dist.percentA,
      percentB: dist.percentB,
    ));
  }

  void _onNextQuestion(
    NextQuestion event,
    Emitter<SessionState> emit,
  ) {
    final s = state;
    if (s is! SessionActive || s.isLastQuestion) return;

    final nextIndex = s.currentQuestionIndex + 1;
    final dist = MockData.answerDistributions[nextIndex];

    // Mise à jour mock des scores
    final updated = s.participants.asMap().entries.map((e) {
      final bonus = (e.key == 0) ? 20 : (e.key == 1 ? 10 : 5);
      return e.value.copyWith(score: e.value.score + bonus);
    }).toList();

    emit(s.copyWith(
      currentQuestionIndex: nextIndex,
      participants: updated,
      percentA: dist.percentA,
      percentB: dist.percentB,
    ));
  }

  void _onEndSession(
    EndSession event,
    Emitter<SessionState> emit,
  ) {
    final s = state;
    if (s is! SessionActive) return;

    final sorted = [...s.participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    emit(SessionFinished(
      quiz: s.quiz,
      finalLeaderboard: sorted,
    ));
  }
}
