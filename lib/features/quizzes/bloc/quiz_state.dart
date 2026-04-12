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
  const QuizQuestion({
    required this.id,
    required this.text,
    this.optionA = '',
    this.optionB = '',
    this.optionC = '',
    this.optionD = '',
    this.correctOption = 'A',
    this.orderIndex = 0,
  });

  final String id;
  final String text;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption; // 'A' | 'B' | 'C' | 'D'
  final int orderIndex;

  @override
  List<Object?> get props =>
      [id, text, optionA, optionB, optionC, optionD, correctOption, orderIndex];
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
    this.isSaving = false,
  });
  final List<Quiz> quizzes;
  final Quiz? selectedQuiz;
  final bool isSaving; 

  QuizLoaded copyWith({List<Quiz>? quizzes, Quiz? selectedQuiz, bool? isSaving}) => QuizLoaded(
        quizzes: quizzes ?? this.quizzes,
        selectedQuiz: selectedQuiz ?? this.selectedQuiz,
        isSaving: isSaving ?? this.isSaving,
      );

  @override
  List<Object?> get props => [quizzes, selectedQuiz, isSaving];
}

class QuizError extends QuizState {
  const QuizError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
