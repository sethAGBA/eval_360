import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/projects/presentation/pages/project_form_page.dart';
import '../../features/shared/widgets/main_layout.dart';

/// Configuration du routeur de l'application
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Route de login (sans layout)
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

    // Routes avec layout principal
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        // Dashboard
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),

        // Projets
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsListPage(),
        ),

        // Création d'un projet
        GoRoute(
          path: '/projects/new',
          builder: (context, state) => const ProjectFormPage(),
        ),

        // Édition d'un projet
        GoRoute(
          path: '/projects/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProjectFormPage(projectId: int.tryParse(id));
          },
        ),

        // Détail d'un projet
        GoRoute(
          path: '/projects/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProjectDetailPage(projectId: id);
          },
        ),
      ],
    ),
  ],

  // Redirection pour gérer l'authentification
  redirect: (context, state) {
    // TODO: Vérifier si l'utilisateur est connecté
    // Pour l'instant, on laisse passer
    return null;
  },

  // Gestion des erreurs
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page non trouvée',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Retour au tableau de bord'),
          ),
        ],
      ),
    ),
  ),
);
