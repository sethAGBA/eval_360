import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eval_360/core/models/rapport_hebdo.dart';
import 'package:eval_360/core/models/ligne_rapport.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// PROVIDERS POUR LES RAPPORTS HEBDOMADAIRES
// ============================================================================

/// Provider pour récupérer tous les rapports hebdomadaires
final weeklyReportsProvider = FutureProvider<List<RapportHebdo>>((ref) async {
  return await DatabaseService.instance.getWeeklyReports();
});

/// Filtres pour les rapports hebdomadaires
class WeeklyReportFilters {
  final int? agentId;
  final StatutValidationRapport? statut;
  final int? annee;

  const WeeklyReportFilters({this.agentId, this.statut, this.annee});

  WeeklyReportFilters copyWith({
    int? agentId,
    StatutValidationRapport? statut,
    int? annee,
  }) {
    return WeeklyReportFilters(
      agentId: agentId ?? this.agentId,
      statut: statut ?? this.statut,
      annee: annee ?? this.annee,
    );
  }
}

/// Provider pour l'état des filtres
final weeklyReportFiltersProvider = StateProvider<WeeklyReportFilters>((ref) {
  return const WeeklyReportFilters();
});

/// Provider pour les rapports filtrés
final filteredWeeklyReportsProvider = FutureProvider<List<RapportHebdo>>((
  ref,
) async {
  final filters = ref.watch(weeklyReportFiltersProvider);
  // Watch the base weeklyReportsProvider to ensure refresh when data changes
  await ref.watch(weeklyReportsProvider.future);

  return await DatabaseService.instance.getWeeklyReports(
    agentId: filters.agentId,
    statut: filters.statut,
    annee: filters.annee,
  );
});

/// Modèle combiné pour un rapport et ses lignes
class WeeklyReportWithLines {
  final RapportHebdo rapport;
  final List<LigneRapport> lignes;

  const WeeklyReportWithLines({required this.rapport, required this.lignes});
}

/// Provider pour récupérer un rapport complet par ID
final weeklyReportDetailProvider =
    FutureProvider.family<WeeklyReportWithLines?, int>((ref, id) async {
      final rapport = await DatabaseService.instance.getWeeklyReportById(id);
      if (rapport == null) return null;

      final lignes = await DatabaseService.instance.getLignesByRapportId(id);
      return WeeklyReportWithLines(rapport: rapport, lignes: lignes);
    });
