import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(const QuizInitial()) {
    on<LoadQuizzes>(_onLoadQuizzes);
    on<CreateQuiz>(_onCreateQuiz);
    on<DeleteQuiz>(_onDeleteQuiz);
    on<SelectQuiz>(_onSelectQuiz);
  }

  // ── Données mock initiales ──────────────────────────────────────
  static final _mockQuizzes = [
    const Quiz(
      id: 'q1',
      title: 'JavaScript Basics',
      description: 'Les fondamentaux de JS',
      questions: [
        QuizQuestion(id: 'q1-1', text: 'What is a closure?'),
        QuizQuestion(id: 'q1-2', text: 'What is a Promise in JavaScript?'),
        QuizQuestion(id: 'q1-3', text: 'Explain event bubbling'),
        QuizQuestion(id: 'q1-4', text: 'What is hoisting?'),
        QuizQuestion(id: 'q1-5', text: 'Difference between == and ===?'),
      ],
    ),
    const Quiz(
      id: 'q2',
      title: 'React Fundamentals',
      description: 'Concepts clés de React',
      questions: [
        QuizQuestion(id: 'q2-1', text: 'What is JSX?'),
        QuizQuestion(id: 'q2-2', text: 'Explain useState hook'),
        QuizQuestion(id: 'q2-3', text: 'What is the Virtual DOM?'),
        QuizQuestion(id: 'q2-4', text: 'Explain useEffect'),
        QuizQuestion(id: 'q2-5', text: 'What are React keys?'),
        QuizQuestion(
            id: 'q2-6', text: 'Controlled vs uncontrolled components?'),
        QuizQuestion(id: 'q2-7', text: 'What is prop drilling?'),
        QuizQuestion(id: 'q2-8', text: 'Explain context API'),
      ],
    ),
    const Quiz(
      id: 'q3',
      title: 'CSS Tricks',
      description: 'Astuces CSS avancées',
      questions: [
        QuizQuestion(id: 'q3-1', text: 'What is the box model?'),
        QuizQuestion(id: 'q3-2', text: 'Flexbox vs Grid?'),
        QuizQuestion(id: 'q3-3', text: 'What is specificity?'),
        QuizQuestion(id: 'q3-4', text: 'Explain CSS variables'),
      ],
    ),
  ];

  Future<void> _onLoadQuizzes(
    LoadQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    emit(QuizLoaded(quizzes: List.from(_mockQuizzes)));
  }

  Future<void> _onCreateQuiz(
    CreateQuiz event,
    Emitter<QuizState> emit,
  ) async {
    final current = state;
    if (current is! QuizLoaded) return;

    final newQuiz = Quiz(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      title: event.title,
      description: event.description,
    );

    emit(current.copyWith(
      quizzes: [...current.quizzes, newQuiz],
    ));
  }

  void _onDeleteQuiz(
    DeleteQuiz event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizLoaded) return;

    emit(current.copyWith(
      quizzes: current.quizzes.where((q) => q.id != event.quizId).toList(),
    ));
  }

  void _onSelectQuiz(
    SelectQuiz event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizLoaded) return;

    final quiz = current.quizzes.firstWhere(
      (q) => q.id == event.quizId,
      orElse: () => current.quizzes.first,
    );
    emit(current.copyWith(selectedQuiz: quiz));
  }
}
