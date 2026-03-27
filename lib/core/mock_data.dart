// Données fictives partagées dans toute l'application

// ── Quiz ────────────────────────────────────────────────────────────
class MockQuiz {
  final String id;
  final String title;
  final int questionCount;

  const MockQuiz({
    required this.id,
    required this.title,
    required this.questionCount,
  });
}

// ── Session ─────────────────────────────────────────────────────────
class MockParticipant {
  final String id;
  final String name;
  final int score;

  const MockParticipant({
    required this.id,
    required this.name,
    required this.score,
  });
}

class MockAnswerDistribution {
  final int percentA;
  final int percentB;
  const MockAnswerDistribution(
      {required this.percentA, required this.percentB});
}

class MockData {
  MockData._();

  // ── Quizzes ──
  static const quizzes = [
    MockQuiz(id: 'q1', title: 'JavaScript Basics', questionCount: 5),
    MockQuiz(id: 'q2', title: 'React Fundamentals', questionCount: 8),
    MockQuiz(id: 'q3', title: 'CSS Tricks', questionCount: 4),
  ];

  // ── Session ──
  static const sessionCode = 'AB12';

  static const participants = [
    MockParticipant(id: 'p1', name: 'Alice', score: 120),
    MockParticipant(id: 'p2', name: 'Bob', score: 90),
    MockParticipant(id: 'p3', name: 'Carol', score: 80),
    MockParticipant(id: 'p4', name: 'Dave', score: 60),
  ];

  /// Distribution des réponses A/B par question (index = numéro de question)
  static const answerDistributions = [
    MockAnswerDistribution(percentA: 44, percentB: 45),
    MockAnswerDistribution(percentA: 66, percentB: 27),
    MockAnswerDistribution(percentA: 55, percentB: 38),
    MockAnswerDistribution(percentA: 80, percentB: 15),
    MockAnswerDistribution(percentA: 90, percentB: 8),
  ];
}
