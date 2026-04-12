part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

/// Charger la liste des quizzes au démarrage
class LoadQuizzes extends QuizEvent {
  const LoadQuizzes();
}

/// Créer un nouveau quiz
class CreateQuiz extends QuizEvent {
  const CreateQuiz({
    required this.title,
    this.description = '',
    required this.createdBy,
    this.questions = const [],
  });
  final String title;
  final String description;
  final String createdBy;
  final List<QuizQuestion> questions;

  @override
  List<Object?> get props => [title, description, createdBy, questions];
}

/// Supprimer un quiz
class DeleteQuiz extends QuizEvent {
  const DeleteQuiz({required this.quizId});
  final String quizId;
  @override
  List<Object?> get props => [quizId];
}

/// Sélectionner un quiz (pour le lancer ou le modifier)
class SelectQuiz extends QuizEvent {
  const SelectQuiz({required this.quizId});
  final String quizId;
  @override
  List<Object?> get props => [quizId];
}
