import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../../../core/theme.dart';

// Modèle temporaire (local, avant envoi)
class _DraftQuestion {
  _DraftQuestion({
    required this.text,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });
  String text;
  String optionA, optionB, optionC, optionD;
  String correctOption; // 'A' | 'B' | 'C' | 'D'
}

class CreateQuizScreen extends StatefulWidget {
  // Le userId du host connecté (nécessaire pour createdBy)
  final String hostUserId;
  const CreateQuizScreen({super.key, required this.hostUserId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<_DraftQuestion> _questions = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _QuestionFormSheet(
        onSave: (draft) {
          setState(() => _questions.add(draft));
        },
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  void _saveQuiz() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre est obligatoire'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoute au moins une question'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Convertir les drafts en QuizQuestion (modèle Bloc)
    final quizQuestions = _questions.asMap().entries.map((e) {
      final q = e.value;
      return QuizQuestion(
        id: '', // sera généré par le backend
        text: q.text,
        optionA: q.optionA,
        optionB: q.optionB,
        optionC: q.optionC,
        optionD: q.optionD,
        correctOption: q.correctOption,
        orderIndex: e.key,
      );
    }).toList();

    context.read<QuizBloc>().add(CreateQuiz(
          title: title,
          description: _descCtrl.text.trim(),
          createdBy: widget.hostUserId,
          questions: quizQuestions,
        ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('New Quiz'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            final isSaving = state is QuizLoaded && state.isSaving;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Title'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration:
                        const InputDecoration(hintText: 'JavaScript Basics'),
                  ),
                  const SizedBox(height: 16),

                  const _Label('Description'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'Optional description...'),
                  ),
                  const SizedBox(height: 24),

                  // ── Questions ──────────────────────────────
                  _Label('Questions (${_questions.length})'),
                  const SizedBox(height: 10),

                  ..._questions.asMap().entries.map((e) => _QuestionSummaryCard(
                        index: e.key,
                        draft: e.value,
                        onRemove: () => _removeQuestion(e.key),
                      )),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add question'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveQuiz,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Quiz',
                              style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Carte résumé d'une question ──────────────────────────────────────

class _QuestionSummaryCard extends StatelessWidget {
  const _QuestionSummaryCard({
    required this.index,
    required this.draft,
    required this.onRemove,
  });
  final int index;
  final _DraftQuestion draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.accent),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.text,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Correct: ${draft.correctOption}  •  4 options',
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textHint),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Sheet : formulaire d'une question ───────────────────────────────

class _QuestionFormSheet extends StatefulWidget {
  const _QuestionFormSheet({required this.onSave});
  final void Function(_DraftQuestion) onSave;

  @override
  State<_QuestionFormSheet> createState() => _QuestionFormSheetState();
}

class _QuestionFormSheetState extends State<_QuestionFormSheet> {
  final _textCtrl = TextEditingController();
  final _optACtrl = TextEditingController();
  final _optBCtrl = TextEditingController();
  final _optCCtrl = TextEditingController();
  final _optDCtrl = TextEditingController();
  String _correct = 'A';

  @override
  void dispose() {
    _textCtrl.dispose();
    _optACtrl.dispose();
    _optBCtrl.dispose();
    _optCCtrl.dispose();
    _optDCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final text = _textCtrl.text.trim();
    final a = _optACtrl.text.trim();
    final b = _optBCtrl.text.trim();
    final c = _optCCtrl.text.trim();
    final d = _optDCtrl.text.trim();

    if (text.isEmpty || a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont obligatoires')),
      );
      return;
    }

    widget.onSave(_DraftQuestion(
      text: text,
      optionA: a,
      optionB: b,
      optionC: c,
      optionD: d,
      correctOption: _correct,
    ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Question',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Texte de la question
            const _Label('Question'),
            const SizedBox(height: 6),
            TextField(
              controller: _textCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'What is a closure?'),
            ),
            const SizedBox(height: 16),

            // 4 options
            ...['A', 'B', 'C', 'D'].map((letter) {
              final ctrl = switch (letter) {
                'A' => _optACtrl,
                'B' => _optBCtrl,
                'C' => _optCCtrl,
                _ => _optDCtrl,
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: ctrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Option $letter',
                    prefixIcon: Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: _correct == letter
                              ? AppColors.accent
                              : AppColors.textHint,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Sélection de la bonne réponse
            const _Label('Correct answer'),
            const SizedBox(height: 8),
            Row(
              children: ['A', 'B', 'C', 'D'].map((letter) {
                final selected = _correct == letter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _correct = letter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent.withOpacity(0.15)
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color:
                              selected ? AppColors.accent : AppColors.textHint,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Add Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Label helper ─────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
}
