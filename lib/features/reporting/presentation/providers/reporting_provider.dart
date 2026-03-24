import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/services/database_service.dart';

// ---------------------------------------------------------------------------
// Providers pour le module Reporting & Statistiques (Module 11)
// ---------------------------------------------------------------------------

/// Filtre d'année sélectionné pour les graphiques
final statsYearFilterProvider = StateProvider<int>((ref) => DateTime.now().year);

/// KPIs globaux : consolidation de toutes les données
final globalStatsProvider = FutureProvider<GlobalStats>((ref) async {
  final year = ref.watch(statsYearFilterProvider);
  final stats = await DatabaseService.instance.getDashboardStats();
  final budgetMap = await DatabaseService.instance.getGlobalBudgetStats();
  return GlobalStats(
    totalProjects: stats.totalProjects,
    activeProjects: stats.activeProjects,
    budgetTotal: budgetMap['budgetTotal'] ?? 0.0,
    budgetExecute: budgetMap['budgetExecute'] ?? 0.0,
    totalBeneficiaires: stats.totalBeneficiaires,
    tauxIndicateurs: stats.tauxIndicateurs,
    year: year,
  );
});

/// Taux d'exécution budgétaire par projet
final budgetByProjectProvider = FutureProvider<List<ProjectBudgetStat>>((ref) async {
  final projects = await DatabaseService.instance.getProjects();
  final result = <ProjectBudgetStat>[];
  for (final project in projects) {
    if (project.id == null) continue;
    final stats = await DatabaseService.instance.getProjectStats(project.id!);
    result.add(ProjectBudgetStat(
      projectName: project.titre,
      budgetTotal: stats.budgetTotal,
      budgetExecute: stats.budgetExecute,
      tauxExecution: stats.tauxExecutionBudget,
    ));
  }
  return result;
});

/// Stats des activités par projet
final activiteStatsByProjectProvider = FutureProvider<List<ProjectActiviteStat>>((ref) async {
  final projects = await DatabaseService.instance.getProjects();
  final result = <ProjectActiviteStat>[];
  for (final project in projects) {
    if (project.id == null) continue;
    final stats = await DatabaseService.instance.getProjectStats(project.id!);
    result.add(ProjectActiviteStat(
      projectName: project.titre,
      total: stats.nombreActivites,
      tauxAtteinte: stats.tauxExecutionBudget,
    ));
  }
  return result;
});

// ---------------------------------------------------------------------------
// Modèles de données pour les statistiques
// ---------------------------------------------------------------------------

class GlobalStats {
  final int totalProjects;
  final int activeProjects;
  final double budgetTotal;
  final double budgetExecute;
  final int totalBeneficiaires;
  final double tauxIndicateurs;
  final int year;

  const GlobalStats({
    required this.totalProjects,
    required this.activeProjects,
    required this.budgetTotal,
    required this.budgetExecute,
    required this.totalBeneficiaires,
    required this.tauxIndicateurs,
    required this.year,
  });

  double get tauxExecutionBudget {
    if (budgetTotal == 0) return 0;
    return (budgetExecute / budgetTotal * 100).clamp(0.0, 100.0);
  }
}

class ProjectBudgetStat {
  final String projectName;
  final double budgetTotal;
  final double budgetExecute;
  final double tauxExecution;

  const ProjectBudgetStat({
    required this.projectName,
    required this.budgetTotal,
    required this.budgetExecute,
    required this.tauxExecution,
  });
}

class ProjectActiviteStat {
  final String projectName;
  final int total;
  final double tauxAtteinte;

  const ProjectActiviteStat({
    required this.projectName,
    required this.total,
    required this.tauxAtteinte,
  });
}
