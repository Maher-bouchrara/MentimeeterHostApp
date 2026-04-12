import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../../../core/theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'create_quiz_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onLaunch,
    this.hostUserId,
  });

  /// ID du host (user authentifié)
  final String? hostUserId;

  /// Callback quand le host clique "Launch" sur un quiz
  final void Function(String quizId)? onLaunch;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les quizzes au démarrage
    context.read<QuizBloc>().add(const LoadQuizzes());
  }

  void _openCreateQuiz() {
    if (widget.hostUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: User ID tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateQuizScreen(hostUserId: widget.hostUserId!),
      ),
    );
  }

  void _launchQuiz(BuildContext ctx, String quizId) {
    ctx.read<QuizBloc>().add(SelectQuiz(quizId: quizId));
    widget.onLaunch?.call(quizId);
  }

  @override
  Widget build(BuildContext context) {
    final email =
        (context.read<AuthBloc>().state as AuthAuthenticated?)?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Quizzes'),
            if (email.isNotEmpty)
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          // Bouton déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (ctx, state) {
          if (state is QuizLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (state is QuizError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.danger)),
            );
          }

          if (state is QuizLoaded) {
            return Column(
              children: [
                // ── Header section ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.quizzes.length} quiz${state.quizzes.length > 1 ? 'zes' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      // ── Bouton + New ──
                      ElevatedButton.icon(
                        onPressed: _openCreateQuiz,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Liste des quizzes ────────────────────────────
                Expanded(
                  child: state.quizzes.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.quizzes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _QuizCard(
                            quiz: state.quizzes[i],
                            onLaunch: () =>
                                _launchQuiz(ctx, state.quizzes[i].id),
                            onDelete: () => ctx.read<QuizBloc>().add(
                                  DeleteQuiz(quizId: state.quizzes[i].id),
                                ),
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Aucun quiz pour l\'instant',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Appuie sur + New pour créer ton premier quiz',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      );
}

// ── Widget carte quiz ────────────────────────────────────────────────
class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
    required this.onLaunch,
    required this.onDelete,
  });

  final Quiz quiz;
  final VoidCallback onLaunch;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ── Infos ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quiz.questionCount} question${quiz.questionCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Actions ──
          Row(
            children: [
              // Supprimer
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.textHint),
                onPressed: onDelete,
                tooltip: 'Supprimer',
              ),
              const SizedBox(width: 4),
              // Launch
              OutlinedButton(
                onPressed: onLaunch,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                ),
                child: const Text(
                  'Launch',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
