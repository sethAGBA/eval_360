import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/projet.dart';
import '../../../core/models/depense.dart';
import '../../../core/models/activite.dart';
import '../../../core/services/database_service.dart';

/// Provider pour les projets actifs
final activeProjectsProvider = FutureProvider<List<Projet>>((ref) async {
  return await DatabaseService.instance.getProjects(
    statut: ProjetStatut.actif,
  );
});

/// Provider pour le nombre de projets actifs
final activeProjectsCountProvider = FutureProvider<int>((ref) async {
  final projects = await ref.watch(activeProjectsProvider.future);
  return projects.length;
});

/// Provider pour tous les projets
final allProjectsProvider = FutureProvider<List<Projet>>((ref) async {
  return await DatabaseService.instance.getProjects();
});

/// Provider pour le budget total
final totalBudgetProvider = FutureProvider<double>((ref) async {
  final projects = await ref.watch(allProjectsProvider.future);
  return projects.fold<double>(0, (sum, p) => sum + p.budgetTotal);
});

/// Provider pour le budget dépensé
final spentBudgetProvider = FutureProvider<double>((ref) async {
  final projects = await ref.watch(allProjectsProvider.future);
  double totalSpent = 0;

  for (final project in projects) {
    final depenses = await DatabaseService.instance.getDepensesByProject(project.id!);
    totalSpent += depenses.fold<double>(0, (sum, d) => sum + d.montant);
  }

  return totalSpent;
});

/// Provider pour le pourcentage d'exécution budgétaire
final budgetExecutionPercentageProvider = FutureProvider<double>((ref) async {
  final totalBudget = await ref.watch(totalBudgetProvider.future);
  final spentBudget = await ref.watch(spentBudgetProvider.future);

  if (totalBudget == 0) return 0;
  return (spentBudget / totalBudget) * 100;
});

/// Provider pour les activités avec risques critiques
final activitiesWithCriticalRisksProvider = FutureProvider<List<Activite>>((ref) async {
  try {
    final projects = await ref.watch(allProjectsProvider.future);
    final activitiesWithRisks = <Activite>[];

    for (final project in projects) {
      final activites = await DatabaseService.instance.getActivitesByProject(project.id!);
      
      for (final activite in activites) {
        // Vérifier si l'activité a des risques critiques
        // Les risques sont stockés en JSON ou en texte dans le champ 'risques'
        if (activite.risques != null && activite.risques!.isNotEmpty) {
          // Si le champ risques contient "critique" ou "critical"
          if (activite.risques!.toLowerCase().contains('critique') ||
              activite.risques!.toLowerCase().contains('critical')) {
            activitiesWithRisks.add(activite);
          }
        }
      }
    }

    return activitiesWithRisks;
  } catch (e) {
    return [];
  }
});

/// Provider pour le nombre de risques critiques
final criticalRisksCountProvider = FutureProvider<int>((ref) async {
  final activities = await ref.watch(activitiesWithCriticalRisksProvider.future);
  return activities.length;
});

/// Provider pour les tâches non complétées (alertes)
final pendingTasksProvider = FutureProvider<int>((ref) async {
  try {
    final projects = await ref.watch(allProjectsProvider.future);
    int pendingCount = 0;

    for (final project in projects) {
      final activites = await DatabaseService.instance.getActivitesByProject(project.id!);
      
      for (final activite in activites) {
        // Compter les activités avec un taux d'avancement < 100%
        if (activite.pourcentageAvancement < 100) {
          pendingCount++;
        }
      }
    }

    return pendingCount;
  } catch (e) {
    return 0;
  }
});

/// Stats consolidées pour le bottom bar
final bottomBarStatsProvider = FutureProvider<BottomBarStats>((ref) async {
  final activeCount = await ref.watch(activeProjectsCountProvider.future);
  final budgetExecution = await ref.watch(budgetExecutionPercentageProvider.future);
  final criticalRisks = await ref.watch(criticalRisksCountProvider.future);
  final pendingTasks = await ref.watch(pendingTasksProvider.future);

  return BottomBarStats(
    activeProjectsCount: activeCount,
    budgetExecutionPercentage: budgetExecution,
    criticalRisksCount: criticalRisks,
    pendingTasksCount: pendingTasks,
  );
});

/// Modèle pour les stats du bottom bar
class BottomBarStats {
  final int activeProjectsCount;
  final double budgetExecutionPercentage;
  final int criticalRisksCount;
  final int pendingTasksCount;

  BottomBarStats({
    required this.activeProjectsCount,
    required this.budgetExecutionPercentage,
    required this.criticalRisksCount,
    required this.pendingTasksCount,
  });
}
