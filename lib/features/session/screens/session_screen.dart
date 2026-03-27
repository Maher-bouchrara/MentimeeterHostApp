import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/session_bloc.dart';
import '../../../core/theme.dart';
import '../../quizzes/bloc/quiz_bloc.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionBloc()..add(StartSession(quiz: quiz)),
      child: const _SessionView(),
    );
  }
}

// ── Vue principale ────────────────────────────────────────────────────
class _SessionView extends StatelessWidget {
  const _SessionView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (ctx, state) => switch (state) {
        SessionIdle() => _buildLoading(),
        SessionActive s => _buildActive(ctx, s),
        SessionFinished s => _buildFinished(ctx, s),
        _ => _buildLoading(),
      },
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────
  Widget _buildLoading() => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text('Démarrage de la session...',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );

  // ── Session LIVE ─────────────────────────────────────────────────────
  Widget _buildActive(BuildContext ctx, SessionActive s) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _liveAppBar(s),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _QuestionCard(state: s),
            const SizedBox(height: 12),
            _AnswerBars(state: s),
            const SizedBox(height: 12),
            _Leaderboard(state: s),
            const SizedBox(height: 20),
            _ActionButtons(state: s),
          ],
        ),
      ),
    );
  }

  AppBar _liveAppBar(SessionActive s) => AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Badge LIVE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success),
              ),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(s.quiz.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('Code: ${s.sessionCode}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      );

  // ── Session terminée ─────────────────────────────────────────────────
  Widget _buildFinished(BuildContext ctx, SessionFinished s) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Résultats finaux'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.emoji_events, color: AppColors.warn, size: 64),
              const SizedBox(height: 12),
              Text(s.quiz.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              ...s.finalLeaderboard.take(5).toList().asMap().entries.map(
                    (e) => _PodiumRow(rank: e.key + 1, p: e.value),
                  ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Retour au dashboard'),
              ),
            ],
          ),
        ),
      );
}

// ── Question card ─────────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.state});
  final SessionActive state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${state.currentQuestionIndex + 1} / ${state.quiz.questions.length}',
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(state.currentQuestion.text,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Waiting for answers...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Barres de réponses ───────────────────────────────────────────────
class _AnswerBars extends StatelessWidget {
  const _AnswerBars({required this.state});
  final SessionActive state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _Bar(
              label: 'A',
              percent: state.percentA / 100,
              color: AppColors.accent),
          const SizedBox(height: 12),
          _Bar(
              label: 'B',
              percent: state.percentB / 100,
              color: const Color(0xFF484F58)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.percent, required this.color});
  final String label;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: AppColors.card,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${(percent * 100).round()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ── Leaderboard ──────────────────────────────────────────────────────
class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.state});
  final SessionActive state;

  @override
  Widget build(BuildContext context) {
    final sorted = [...state.participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participants ${state.participants.length} connected',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...sorted.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14)),
                    Text('${p.score} pts',
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Boutons action ───────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.state});
  final SessionActive state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isLastQuestion
                ? null
                : () => context.read<SessionBloc>().add(const NextQuestion()),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(state.isLastQuestion ? 'Dernière' : 'Next question'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _confirmEnd(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size(0, 50),
            ),
            child: const Text('End Session'),
          ),
        ),
      ],
    );
  }

  void _confirmEnd(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Terminer la session ?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        content: const Text('Les résultats seront affichés.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<SessionBloc>().add(const EndSession());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}

// ── Podium ───────────────────────────────────────────────────────────
class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.rank, required this.p});
  final int rank;
  final Participant p;

  static const _colors = [
    AppColors.warn,
    Color(0xFFB0B8C1),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final color = rank <= 3 ? _colors[rank - 1] : AppColors.textHint;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$rank',
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(p.name,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15)),
          ),
          Text('${p.score} pts',
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
