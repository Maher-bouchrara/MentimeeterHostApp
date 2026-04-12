import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/quiz_repository.dart';
part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(const QuizInitial()) {
    on<LoadQuizzes>(_onLoadQuizzes);
    on<CreateQuiz>(_onCreateQuiz);
    on<DeleteQuiz>(_onDeleteQuiz);
    on<SelectQuiz>(_onSelectQuiz);
  }

  final _repo = QuizRepository.instance;

  Future<void> _onLoadQuizzes(
    LoadQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    try {
      final quizzes = await _repo.fetchQuizzes();
      emit(QuizLoaded(quizzes: quizzes));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onCreateQuiz(CreateQuiz event, Emitter<QuizState> emit) async {

    final current = state;
    if (current is! QuizLoaded) return;

    emit(QuizLoaded(quizzes: current.quizzes, isSaving: true));

    try{
      final newQuiz = await _repo.createQuizWithQuestions(
        title: event.title, 
        description: event.description, 
        createdBy: event.createdBy, 
        questions: event.questions);
        emit(QuizLoaded(quizzes: [...current.quizzes, newQuiz]));
    }catch(e){
      emit(QuizError(message: e.toString()));
    }

  }

  void _onDeleteQuiz(DeleteQuiz event, Emitter<QuizState> emit) async {
    final current = state;
    if (current is! QuizLoaded) return;
    try{
      await _repo.deleteQuiz(event.quizId);
      emit(current.copyWith(quizzes: current.quizzes.where((q) => q.id != event.quizId).toList()));

    }catch(e){
      emit(QuizError(message: e.toString()));
    }
  }

  void _onSelectQuiz(
    SelectQuiz event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizLoaded) return;
    final quiz = current.quizzes.firstWhere((q) => q.id == event.quizId, orElse: () => current.quizzes.first);
    emit(current.copyWith(selectedQuiz: quiz));
  }
}
