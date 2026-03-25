import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/models/tache.dart';

/// Provider pour les activités du jour
final activitiesOfTheDayProvider = FutureProvider<List<Activite>>((ref) async {
  return await DatabaseService.instance.getActivitesDuJour();
});

/// Provider pour les tâches en attente (à faire ou en cours)
final pendingTasksProvider = FutureProvider<List<Tache>>((ref) async {
  final allTasks = await DatabaseService.instance.getTasks();
  return allTasks.where((tache) => 
    tache.statut == TacheStatut.aFaire || tache.statut == TacheStatut.enCours
  ).toList();
});

/// Modèle pour une alerte sur le dashboard
class DashboardAlert {
  final String title;
  final String description;
  final String severity; // 'critical', 'warning', 'info'

  DashboardAlert({
    required this.title,
    required this.description,
    required this.severity,
  });
}

/// Provider pour les alertes critiques (projets en retard, tâches en retard)
final criticalAlertsProvider = FutureProvider<List<DashboardAlert>>((ref) async {
  final List<DashboardAlert> alerts = [];
  final db = DatabaseService.instance;

  // 1. Projets en retard
  final projects = await db.getProjects();
  for (final projet in projects) {
    if (projet.estEnRetard) {
      alerts.add(
        DashboardAlert(
          title: 'Projet en retard',
          description: 'Le projet "${projet.titre}" a dépassé sa date de fin prévue.',
          severity: 'critical',
        ),
      );
    }
  }

  // 2. Tâches en retard (échéance dépassée et non terminées)
  final tasks = await db.getTasks();
  final now = DateTime.now();
  for (final tache in tasks) {
    if (tache.statut != TacheStatut.termine && tache.dateEcheance != null) {
      if (tache.dateEcheance!.isBefore(now)) {
        alerts.add(
          DashboardAlert(
            title: 'Tâche en retard',
            description: 'La tâche "${tache.titre}" devait être terminée le ${tache.dateEcheance!.day}/${tache.dateEcheance!.month}/${tache.dateEcheance!.year}.',
            severity: 'warning',
          ),
        );
      }
    }
  }

  // S'il n'y a pas d'alertes, on peut ajouter une alerte info
  if (alerts.isEmpty) {
    alerts.add(
      DashboardAlert(
        title: 'Tout est à jour',
        description: 'Aucun projet ni tâche en retard.',
        severity: 'info',
      ),
    );
  }

  return alerts;
});
