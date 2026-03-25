import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/projects/presentation/pages/project_form_page.dart';
import '../../features/reports/presentation/pages/weekly_reports_list_page.dart';
import '../../features/reports/presentation/pages/weekly_report_form_page.dart';
import '../../features/reports/presentation/pages/monthly_reports_list_page.dart';
import '../../features/reports/presentation/pages/monthly_report_detail_page.dart';
import '../../features/tasks/presentation/pages/tasks_kanban_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../features/agents/presentation/pages/agents_list_page.dart';
import '../../features/agents/presentation/pages/agent_detail_page.dart';
import '../../features/agents/presentation/pages/agent_form_page.dart';
import '../../features/budget/presentation/pages/budget_dashboard_page.dart';
import '../../features/budget/presentation/pages/all_expenses_page.dart';
import '../../features/ged/presentation/pages/ged_page.dart';
import '../../features/ged/presentation/pages/tdr_form_page.dart';
import '../../features/ged/presentation/pages/ordre_mission_form_page.dart';
import '../../features/ged/presentation/pages/rapport_stage_form_page.dart';
import '../../features/ged/presentation/pages/tdrs_list_page.dart';
import '../../features/ged/presentation/pages/ordres_mission_list_page.dart';
import '../../features/ged/presentation/pages/rapports_stage_list_page.dart';
import '../../features/communes/presentation/pages/communes_list_page.dart';
import '../../features/reporting/presentation/pages/reporting_dashboard_page.dart';
import '../../features/partenaires/presentation/pages/partenaires_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/ptba/presentation/pages/ptba_list_page.dart';
import '../../features/ptba/presentation/pages/ptba_detail_page.dart';
import '../../features/ptba/presentation/pages/ptba_form_page.dart';
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

        // -------------------------
        // PTBA / Planification
        // -------------------------
        GoRoute(
          path: '/ptba',
          builder: (context, state) => const PtbaListPage(),
        ),
        GoRoute(
          path: '/ptba/new',
          builder: (context, state) => const PtbaFormPage(),
        ),
        GoRoute(
          path: '/ptba/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PtbaDetailPage(id: id);
          },
        ),
        GoRoute(
          path: '/ptba/:id/edit',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PtbaFormPage(id: id);
          },
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

        // Rapports Hebdomadaires
        GoRoute(
          path: '/reports/weekly',
          builder: (context, state) => const WeeklyReportsListPage(),
        ),
        GoRoute(
          path: '/reports/weekly/new',
          builder: (context, state) => const WeeklyReportFormPage(),
        ),
        GoRoute(
          path: '/reports/weekly/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return WeeklyReportFormPage(rapportId: int.tryParse(id));
          },
        ),

        // Rapports Mensuels
        GoRoute(
          path: '/reports/monthly',
          builder: (context, state) => const MonthlyReportsListPage(),
        ),
        GoRoute(
          path: '/reports/monthly/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return MonthlyReportDetailPage(reportId: int.parse(id));
          },
        ),

        // Tâches (Module 06)
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksKanbanPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const TaskFormPage(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return TaskFormPage(taskId: id);
              },
            ),
          ],
        ),

        // Agents (Module 07)
        GoRoute(
          path: '/agents',
          builder: (context, state) => const AgentsListPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const AgentFormPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return AgentDetailPage(agentId: id);
              },
            ),
            GoRoute(
              path: ':id/edit',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return AgentFormPage(agentId: id);
              },
            ),
          ],
        ),

        // Budget (Module 08)
        GoRoute(
          path: '/budget',
          builder: (context, state) => const BudgetDashboardPage(),
          routes: [
            GoRoute(
              path: 'expenses',
              builder: (context, state) => const AllExpensesPage(),
            ),
          ],
        ),

        // GED (Module 13)
        GoRoute(
          path: '/ged',
          builder: (context, state) => const GedPage(),
        ),

        // Digitalisation (Module 09)
        GoRoute(
          path: '/processus/tdr',
          builder: (context, state) => const TdrFormPage(),
        ),
        GoRoute(
          path: '/processus/ordre-mission',
          builder: (context, state) => const OrdreMissionFormPage(),
        ),
        GoRoute(
          path: '/processus/rapport-stage',
          builder: (context, state) => const RapportStageFormPage(),
        ),
        GoRoute(
          path: '/processus/tdr/list',
          builder: (context, state) => const TdrsListPage(),
        ),
        GoRoute(
          path: '/processus/ordres-mission/list',
          builder: (context, state) => const OrdresMissionListPage(),
        ),
        GoRoute(
          path: '/processus/rapports-stage/list',
          builder: (context, state) => const RapportsStageListPage(),
        ),
        GoRoute(
          path: '/communes',
          builder: (context, state) => const CommunesListPage(),
        ),
        GoRoute(
          path: '/reporting',
          builder: (context, state) => const ReportingDashboardPage(),
        ),
        GoRoute(
          path: '/partenaires',
          builder: (context, state) => const PartenairesListPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
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
