part of 'quiz_bloc.dart';

// ── Modèle Quiz ──────────────────────────────────────────────────────
class Quiz extends Equatable {
  const Quiz({
    required this.id,
    required this.title,
    this.description = '',
    this.questions = const [],
  });  

  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;

  int get questionCount => questions.length;

  Quiz copyWith({
    String? title,
    String? description,
    List<QuizQuestion>? questions,
  }) =>
      Quiz(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        questions: questions ?? this.questions,
      );

  @override
  List<Object?> get props => [id, title, description, questions];
}

// ── Modèle Question ─────────────────────────────────────────────────
class QuizQuestion extends Equatable {
  const QuizQuestion({required this.id, required this.text});
  final String id;
  final String text;
  @override
  List<Object?> get props => [id, text];
}

// ── États ────────────────────────────────────────────────────────────
abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizLoaded extends QuizState {
  const QuizLoaded({
    required this.quizzes,
    this.selectedQuiz,
  });
  final List<Quiz> quizzes;
  final Quiz? selectedQuiz;

  QuizLoaded copyWith({List<Quiz>? quizzes, Quiz? selectedQuiz}) => QuizLoaded(
        quizzes: quizzes ?? this.quizzes,
        selectedQuiz: selectedQuiz ?? this.selectedQuiz,
      );

  @override
  List<Object?> get props => [quizzes, selectedQuiz];
}

class QuizError extends QuizState {
  const QuizError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
