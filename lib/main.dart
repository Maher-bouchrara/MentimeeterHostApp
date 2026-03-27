import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/quizzes/bloc/quiz_bloc.dart';
import 'features/quizzes/screens/dashboard_screen.dart';
// import 'features/session/bloc/session_bloc.dart';
import 'features/session/screens/session_screen.dart';

void main() {
  runApp(const QuizHostApp());
}

class QuizHostApp extends StatelessWidget {
  const QuizHostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<QuizBloc>(create: (_) => QuizBloc()),
        // SessionBloc est créé localement dans SessionScreen
        // (chaque session est indépendante)
      ],
      child: MaterialApp(
        title: 'QuizApp Host',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AppRouter(),
      ),
    );
  }
}

/// Routeur basé sur l'état AuthBloc
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        if (state is AuthAuthenticated) {
          return DashboardScreen(
            onLaunch: (quizId) {
              // Récupère le quiz sélectionné depuis le QuizBloc
              final quizState = ctx.read<QuizBloc>().state;
              if (quizState is! QuizLoaded) return;

              final quiz = quizState.quizzes.firstWhere(
                (q) => q.id == quizId,
                orElse: () => quizState.quizzes.first,
              );

              // Navigation vers SessionScreen
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => SessionScreen(quiz: quiz),
                ),
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
