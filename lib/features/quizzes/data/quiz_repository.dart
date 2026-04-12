import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/graphql_service.dart';
import '../bloc/quiz_bloc.dart';

// ── Queries ─────────────────────────────────────────────────────────

const _quizzesQuery = r'''
  query Quizzes {
    quizzes {
      id
      title
      description
      createdBy
      createdAt
      questions {
        id
        text
        optionA
        optionB
        optionC
        optionD
        correctOption
        orderIndex
      }
    }
  }
''';

// ── Mutations ────────────────────────────────────────────────────────

const _createQuizMutation = r'''
  mutation CreateQuiz($title: String!, $createdBy: String!, $description: String) {
    createQuiz(data: { title: $title, createdBy: $createdBy, description: $description }) {
      id
      title
      description
      createdBy
    }
  }
''';

const _createQuestionMutation = r'''
  mutation CreateQuestion(
    $quizId: String!
    $text: String!
    $optionA: String!
    $optionB: String!
    $optionC: String!
    $optionD: String!
    $correctOption: String!
    $orderIndex: Int!
  ) {
    createQuestion(data: {
      quizId: $quizId
      text: $text
      optionA: $optionA
      optionB: $optionB
      optionC: $optionC
      optionD: $optionD
      correctOption: $correctOption
      orderIndex: $orderIndex
    }) {
      id
      text
      orderIndex
    }
  }
''';

const _deleteQuizMutation = r'''
  mutation RemoveQuiz($id: String!) {
    removeQuiz(id: $id)
  }
''';

// ── Repository ───────────────────────────────────────────────────────

class QuizRepository {
  QuizRepository._();
  static final QuizRepository instance = QuizRepository._();

  GraphQLClient get _client => GraphQLService.instance.client;

  //GetAllQuizzes
  Future<List<Quiz>> fetchQuizzes() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_quizzesQuery),
        fetchPolicy:
            FetchPolicy.networkOnly, // toujours frais depuis le backend
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final list = result.data?['quizzes'] as List<dynamic>? ?? [];
    return list.map(_quizFromJson).toList();
  }

  // Create Quiz + questions
  Future<Quiz> createQuizWithQuestions({
    required String title,
    required String description,
    required String createdBy, // userId Firebase/backend
    required List<QuizQuestion> questions,
  }) async {
    // Create Quiz
    final quizResult = await _client.mutate(
      MutationOptions(
        document: gql(_createQuizMutation),
        variables: {
          'title': title,
          'createdBy': createdBy,
          'description': description.isEmpty ? null : description,
        },
      ),
    );

    if (quizResult.hasException) {
      throw Exception(quizResult.exception.toString());
    }

    final quizData = quizResult.data!['createQuiz'];
    final quizId = quizData['id'] as String;

    // 2. Créer chaque question
    final createdQuestions = <QuizQuestion>[];
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final qResult = await _client.mutate(
        MutationOptions(
          document: gql(_createQuestionMutation),
          variables: {
            'quizId': quizId,
            'text': q.text,
            'optionA': q.optionA,
            'optionB': q.optionB,
            'optionC': q.optionC,
            'optionD': q.optionD,
            'correctOption': q.correctOption,
            'orderIndex': i,
          },
        ),
      );

      if (qResult.hasException) {
        throw Exception('Question ${i + 1} error: ${qResult.exception}');
      }

      final qData = qResult.data!['createQuestion'];
      createdQuestions.add(QuizQuestion(
        id: qData['id'] as String,
        text: q.text,
        optionA: q.optionA,
        optionB: q.optionB,
        optionC: q.optionC,
        optionD: q.optionD,
        correctOption: q.correctOption,
        orderIndex: i,
      ));
    }

    return Quiz(
      id: quizId,
      title: quizData['title'] as String,
      description: quizData['description'] as String? ?? '',
      questions: createdQuestions,
    );
  }

  // Supprimer un quiz
  Future<void> deleteQuiz(String quizId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_deleteQuizMutation),
        variables: {'id': quizId},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  // ── Helper de parsing JSON → modèle ────────────────────────────────

  Quiz _quizFromJson(dynamic json) {
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map((q) => QuizQuestion(
              id: q['id'] as String,
              text: q['text'] as String,
              optionA: q['optionA'] as String? ?? '',
              optionB: q['optionB'] as String? ?? '',
              optionC: q['optionC'] as String? ?? '',
              optionD: q['optionD'] as String? ?? '',
              correctOption: q['correctOption'] as String? ?? 'A',
              orderIndex: q['orderIndex'] as int? ?? 0,
            ))
        .toList();

    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      questions: questions,
    );
  }
}
